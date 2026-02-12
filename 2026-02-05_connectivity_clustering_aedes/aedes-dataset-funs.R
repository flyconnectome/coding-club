aedes_scene <- function() {
  u="https://spelunker.cave-explorer.org/#!middleauth+https://global.daf-apis.com/nglstate/api/v1/6213916184018944"
  u2=fafbseg:::flywire_expandurl(u)
  u2
}

choose_aedes <- function (set = TRUE, url=NULL, datastack_name=NULL)
{
  if(is.null(url))
    url=aedes_scene()
  if(is.null(datastack_name)) {
    sc=fafbseg::ngl_decode_scene(url)
    ll=fafbseg::ngl_layers(sc, type=='segmentation')
    datastack=basename(ll[[1]]$source$url)
  }

  fafbseg::choose_segmentation(url, set = set,
    moreoptions = list(fafbseg.cave.datastack_name = datastack))
}

with_aedes <- function(expr, url=NULL, datastack_name=NULL) {
  op <- choose_aedes(set = TRUE)
  on.exit(options(op))
  force(expr)
}

#' Update root_ids and supervoxel_ids from point information as necessary
#'
#' @details Note that point information will only be used if supervoxel
#' information is missing. Therefore it is essential to delete supervoxel_id for
#' any rows in which the point_xyz is changed.
#'
#' @param df A dataframe containing columns root_id, supervoxel_id, point_xyz
#'
#' @returns A new dataframe with updated ids
#' @export
#'
#' @examples
sequential_update <- function(df) {
  op <- choose_aedes(set = TRUE)
  on.exit(options(op))

  pts_toupdate=with(df,(is.na(supervoxel_id) | supervoxel_id==0)  & !is.na(point_xyz))
  if(any(pts_toupdate)) {
    df[pts_toupdate, "supervoxel_id"] <-
      with(df[pts_toupdate,,drop=F],
           fafbseg::flywire_xyz2id(point_xyz, rawcoords = T, root = F,
                                   voxdims = c(16,16,45), method = 'cloud'))
  }
  df <- df %>% mutate(
    root_id=fafbseg::flywire_updateids(root_id, svids = supervoxel_id)
  )
  df
}


#' Update ids in aedes_main table manually
#'
#' @param update.serial_ids Whether to update the serial_id column uniquely
#'   defining each row
#' @param update_dups Whether to update rows with "duplicate" status (now the
#'   default) and also set the root_duplicated column.
#' @param dry_run Whether to show what would happen rather than doing it.
#'
#' @details This is now part of the scripted updates on flyem but even in future
#'   it may occasionally be useful to trigger this manually.
#'
#'   I have changed the behaviour of the root_duplicated column so that this
#'   will only be ticked for root_ids when there is more than one entry
#'   \emph{after} setting aside any rows with status=duplicate.
#'
#' @export
aedes_flytable_update <- function(update.serial_ids=TRUE, update_dups=TRUE, dry_run=FALSE) {
  # aedes_main=flytable_list_rows(table = 'aedes_main', base = 'aedes')
  aedes_main=fafbseg::flytable_query('select `_id`, root_id, supervoxel_id, point_xyz, serial_id, root_duplicated, status from aedes_main')
  cands <- if(update_dups) {
    dplyr::select(aedes_main, `_id`, root_id, supervoxel_id, point_xyz, root_duplicated, status)
  }
  else {
    aedes_main %>%
      dplyr::filter(status!='duplicate' | is.na(status)) %>%
      dplyr::select(`_id`, root_id, supervoxel_id, point_xyz)
  }

  updated=sequential_update(cands)
  if(update_dups) {
    updated <- updated %>%
      mutate(good_status=is.na(status) | status!='duplicate') %>%
      dplyr::add_count(root_id, good_status) %>%
      dplyr::mutate(root_duplicated=case_when(
       good_status ~ n>1,
       TRUE ~ FALSE
      )) %>%
      dplyr::select(-n, -good_status)
  }
  changed_cells = (updated!=cands) | (is.na(cands) & !is.na(updated))
  changed_rows=rowSums(changed_cells, na.rm = T)>0
  n_changed=sum(changed_rows)
  if(n_changed>0) {
    if(dry_run)
      message("dry run: there are ", n_changed, " changed aedes seatable rows.")
    else {
      message("Updating ", n_changed, " aedes seatable rows.")
      fafbseg::flytable_update_rows(updated[changed_rows, , drop=F], table = 'aedes_main')
    }
  }


  # same procedure for serial_id
  missing_serial=aedes_main %>%
    dplyr::select(`_id`, serial_id) %>%
    dplyr::filter(is.na(serial_id))
  if(isTRUE(nrow(missing_serial)>0)) {
    if(isFALSE(update.serial_ids)) {
      message("Not updating ", nrow(missing_serial), " aedes serial_ids.")
      return(invisible(F))
    }
    last_serial=max(aedes_main$serial_id, na.rm = T)
    missing_serial$serial_id=seq_len(nrow(missing_serial))+last_serial
    if(dry_run)
      message("dry run: there are ", nrow(missing_serial), " aedes serial_ids to update.")
    else {
      message("Updating ", nrow(missing_serial), " aedes serial_ids.")
      fafbseg::flytable_update_rows(missing_serial, table = 'aedes_main')
    }
  }
  invisible(TRUE)
}


#' Write annotations to neuroglancer info file
#'
#' @param anndf Annotation data frame
#' @param dir output directory
#'
#' @returns
#' @export
#'
#' @examples
#' alpn.good=flytable_query("select * from aedes_main where class='ALPN' AND status NOT IN ('duplicate','fragment', 'tiny')")
#' write_info(alpn.good %>%
#'     select(root_id, subsubclass, type, group),
#'   dir = 'aedes_info')
write_info <- function(anndf, dir) {
  dir=normalizePath(dir)
  if(!file.exists(dir))
    dir.create(dir, recursive = T)
  finalf=file.path(dir, "info")
  f <- tempfile(pattern = 'info')
  if(!file.exists(finalf)) {
    update=T
    oldmd5=NA
  } else {
    update=NA
    oldmd5=tools::md5sum(finalf)
  }
  fafbseg::write_nginfo(anndf, f = f, sep="_")
  if(!isTRUE(update)) {
    newmd5=tools::md5sum(f)
    update=!isTRUE(newmd5==oldmd5)
  }
  if(update) {
    message("New version of info file has been written")
    file.copy(f, finalf, overwrite = T)
  } else
    message("info file unchanged")
}


#' Return metadata about Aedes neurons from seatable
#'
#' @param ids Root ids (as character or int64 vector) or a query (see examples)
#' @param ignore.case for queries whether to ignore the case
#' @param fixed whether to treat queries as a fixed string
#' @param version A CAVE materialisation version. The special value 'latest'
#'   uses the most recent version.
#' @param unique Whether to drop rows that have the same root_id. See details.
#'   There is no special logic in choosing which rows to drop, but the dropped
#'   rows are retained as an attribute on the table with a warning so that you
#'   can inspect.
#'
#' @details Note that rows with status `duplicate` or `bad_nucleus` are dropped
#'   even before the `unique` argument is processed.
#'
#' @returns A data frame with appropriate rows based on the \code{ids} argument.
#'
#' @export
#'
#' @examples
#' # implies type
#' aedes_meta("MBON.+")
#' aedes_meta("class:ALPN")
#' # ensure that root ids match the most recent materialisation
#' aedes_meta("class:ALPN", version='latest')
aedes_meta <- function(ids=NULL, ignore.case = F, fixed = F, version=NULL,
                       timestamp=NULL,
                       unique=FALSE) {

  if(is.character(ids) && length(ids)==1 && !fafbseg:::valid_id(ids) && !grepl(":", ids))
    ids=paste0("type:", ids)
  if(is.character(ids) && length(ids)==1 && !fafbseg:::valid_id(ids) && substr(ids,1,1)=="/")
    ids=substr(ids,2, nchar(ids))
  aedes_main=fafbseg::flytable_query("select * from aedes_main WHERE status NOT IN ('duplicate', 'bad_nucleus')")
  if(is.character(ids) && length(ids)==1 && grepl(":", ids)) {
    # it's a query
    ul = unlist(strsplit(ids, ":", fixed = T))
    if (length(ul) != 2)
      stop("Unable to parse aedes id specification!")
    target = ul[1]
    if (!target %in% colnames(aedes_main))
      stop("Unknown field in flywire id specification!")
    query = ul[2]
    if(!fixed && substr(query,1,1)!="^") {
      # regex queries are always considered to be full length
      query=paste0("^", query, "$")
    }
    df=dplyr::filter(aedes_main, grepl(query, .data[[target]], ignore.case = ignore.case, fixed = fixed))
  } else if(is.null(ids))
    df=aedes_main
  else {
    ids <- fafbseg::flywire_ids(ids, integer64 = FALSE, unique = TRUE)
    df=data.frame(root_id=ids)
    if(!is.null(version) || !is.null(timestamp))
      aedes_main$root_id=with_aedes(fafbseg::flywire_updateids(aedes_main$root_id, svids = aedes_main$supervoxel_id, version = version, timestamp = timestamp))
    df=dplyr::left_join(df, aedes_main, by='root_id')
  }

  if (isTRUE(unique)) {
    dups = duplicated(df$root_id)
    ndups = sum(dups)
    if (ndups > 0) {
      dupids = unique(df$root_id[dups])
      duprows = df[df$root_id %in% dupids, , drop = F]
      duprows = duprows[order(duprows$root_id), , drop = F]
      df = df[!dups, , drop = F]
      attr(df, "duprows") = duprows
      warning("Dropping ", sum(dups), " rows containing duplicate root_ids!\n",
              "You can inspect all ", nrow(duprows), " rows with duplicate ids by doing:\n",
              "attr(df, 'duprows')\n", "on your returned data frame (replacing df as appropriate).")
    }
  }

  if(!is.null(version) || !is.null(timestamp)) {
    df$root_id=with_aedes(fafbseg::flywire_updateids(df$root_id, svids = df$supervoxel_id, version = version, timestamp = timestamp))
  }
  df
}

aedes_set_version <- function(which=c("now", "latest")) {
  if(is.character(which) && length(which)>1)
    which=match.arg(which)
  options(aedes.version=which)
}

aedes_get_version <- function(which=getOption('aedes.version', default = 'latest'), version=NULL, timestamp=NULL) {
  if(is.null(which))
    which=getOption('aedes.version', default = 'latest')
  if(!is.null(version)) {
    if(!is.null(timestamp)) {
      warning("ignoring timestamp since version was provided")
      timestamp=NULL
    }
  } else if(is.null(timestamp) & length(which)>=1) {
    if(is.character(which) && length(which)>1)
      which=match.arg(which, c("now", "latest"))
    if(which=='latest' || is.numeric(which))
      version=which
    else
      timestamp=which
  }
  with_aedes(list(version=fafbseg:::flywire_version(version = version),
       timestamp=fafbseg::flywire_timestamp(timestamp = timestamp)))
}

# for use with coconatfly
aedes_cfmeta <- function(ids=NULL, ignore.case = F, fixed = F,
                         which=NULL,
                         version=NULL, timestamp=NULL,
                         unique=TRUE, ...) {
  vi=aedes_get_version(which, timestamp=timestamp, version = version)
  df=aedes_meta(ids, ignore.case = ignore.case, fixed = fixed, unique=unique,
                version=vi$version, timestamp=vi$timestamp, ...)
  df %>%
    dplyr::select(-subsubclass) %>%
    dplyr::rename(id=root_id) %>%
    dplyr::rename(class1=superclass, class2=class, subsubclass=subclass) %>%
    dplyr::rename(class=class1, subclass=class2) %>%
    dplyr::rename(lineage=hemilineage) %>%
    dplyr::mutate(instance=dplyr::case_when(
      is.na(instance) ~ paste0(type, "_", ifelse(is.na(side), "", side)),
      T ~ instance
    ))
}

aedes_ids <- function(ids, ignore.case = F, fixed = F, unique=FALSE,
                      version=NULL, timestamp=NULL) {
  vi=aedes_get_version('now', timestamp=timestamp, version = version)
  am=aedes_meta(ids, ignore.case = ignore.case, fixed = fixed, unique=unique,
                version=vi$version, timestamp=vi$timestamp)
  am$root_id
}


aedes_partner_summary <- function(rootids = rootids,
                                  partners = c("outputs", "inputs"),
                                  threshold = 0,
                                  version = NULL, timestamp = NULL,
                                  synapse_table=getOption('coconatfly.aedes.synapses', default = 'synapses_v2'),
                                  ...) {
  rootids=aedes_ids(rootids, version = version, timestamp = timestamp)
  withr::with_options(choose_aedes(set = F), {
    if(!is.null(version)) {
      version=fafbseg:::flywire_version(version)
      rootids=fafbseg::flywire_latestid(rootids, version = version)
    } else if(!is.null(timestamp)) {
      timestamp=fafbseg::flywire_timestamp(timestamp = timestamp)
      rootids=fafbseg::flywire_latestid(rootids, timestamp = timestamp)
    }
    fafbseg::flywire_partner_summary(rootids = rootids, partners = partners,
                            threshold = threshold,
                            version = version, timestamp = timestamp,
                            synapse_table=synapse_table, method='cave', ...)
  })
}


# for use with coconatfly
aedes_cfpartners <- function(ids, partners = c("outputs", "inputs"),
                             threshold = 1, version='latest', ...) {
  partners=match.arg(partners)
  aedes_partner_summary(ids, partners=partners, threshold = threshold-1L, version=version, ...)
}

aedes_cfpartners_now <- function(ids, partners = c("outputs", "inputs"),
                             threshold = 1, ...) {
  vi=aedes_get_version()
  partners=match.arg(partners)
  aedes_partner_summary(ids, partners=partners, threshold = threshold-1L,
                        version=vi$version, timestamp = vi$timestamp, ...)
}

# for use with coconatfly
if(requireNamespace('coconatfly'))
  coconat::register_dataset('aedes', shortname = 'ab',
                            species = 'Aedes aegyptii', sex='F', age='mated adult',
                            metafun = aedes_cfmeta,
                            partnerfun = aedes_cfpartners_now,
                            namespace = 'coconatfly')

aedes_mirroreg <- function(units=c("microns", 'nm')) {
  um='https://spelunker.cave-explorer.org/#!middleauth+https://global.daf-apis.com/nglstate/api/v1/4693107724517376'
  mann=fafbseg::ngl_annotations(um)
  ptsA=with_aedes(fafbseg::flywire_raw2nm(mann$pointA))
  ptsB=with_aedes(fafbseg::flywire_raw2nm(mann$pointB))
  units=match.arg(units)
  if(units=='microns')
    aedes_mirror.um=nat::tpsreg(rbind(ptsA, ptsB)/1e3, rbind(ptsB, ptsA)/1e3)
  else
    aedes_mirror=nat::tpsreg(rbind(ptsA, ptsB), rbind(ptsB, ptsA))
}

#' Set flytable metadata for some aedes neurons
#'
#' @param ids root_ids specified in any form understood by fafbseg::flywire_ids
#'   except for a query. If missing then `df` must contain a \code{root_id}
#'   column.
#' @param df an optional data.frame of metadata. Will be recycled to an
#'   appropriate length to match \code{ids} argument.
#' @param dry_run logical indicating whether to do a test run (the default, when
#'   \code{T}) or actually update the database.
#' @param update_roots whether to use \code{flywire_latestid} to update the ids
#'   to their latest version.
#'
#' @returns a dataframe of metadata
#' @export
#'
#' @examples
aedes_set_meta <- function(ids=NULL, df=NULL, dry_run=TRUE, update_roots=TRUE) {
  if(is.null(df)) {
    if(!is.data.frame(ids))
      stop("`ids` must be a dataframe if you do not provide a `df` argument!")
    df=ids
  } else if(!is.null(ids)) {
    ids=setdiff(fafbseg::flywire_ids(ids), 0)
    df=cbind(data.frame(root_id=ids), df)
  }

  if(update_roots)
    df$root_id <- with_aedes(flywire_latestid(df$root_id))
  ids <- df$root_id
  ii=flytable_list_selected(ids=ids, table = 'aedes_main', fields = c("_id", "root_id", "status"))
  ii=ii[!ii$status %in% c("bad_nucleus", "duplicate", "not_a_neuron"),
  ]
  if (is.null(ii) || nrow(ii) == 0)
    stop("No rows in flytable for these ids!")
  missing_ids = setdiff(ids, ii$root_id)
  dup_ids = unique(ii$root_id[duplicated(ii$root_id)])
  if (length(missing_ids) > 0)
    message("The following ids are missing from the info table:\n",
            paste(missing_ids, collapse = ","))
  if (length(dup_ids > 0))
    message("The following ids are duplicated in the info table:\n",
            paste(dup_ids, collapse = ","))
  if (length(missing_ids) > 0 || length(dup_ids) > 0)
    stop("Data hygiene problem in flytable:aedes_main!")

  df = dplyr::left_join(df, ii%>% dplyr::select(-status), by = "root_id")

  if(dry_run) df else flytable_update_rows(df, table = 'aedes_main')
}

#' Find a good point on a neuron to associate with annotations
#'
#' @description The chosen point will be close to the "major branch point" of
#'   the neuron Note that by default the L2 skeleton will be rerooted onto an
#'   arbitrary endpoint to ensure that a simplified representation with 1 branch
#'   point can be calculated. Otherwise it is possible for the longest path from
#'   the root point not to contain a branch point.
#'
#'   As a further backup if no major branch point can be identified the original
#'   root point will be used.
#'
#' @param ids root ids
#' @param raw whether to return points in raw (voxel) space or nm
#' @param reroot Whether to reroot the incoming neuron to ensure that the root
#'   point is an end point (leaf node).
#' @param ... additional arguments passed to pbsapply
#' @return an N x 3 matrix of point locations
#' @examples
#' choose_good_point('648518347569414567')
choose_good_point <- function(ids, raw=TRUE, reroot=TRUE, ...) {
  ids=aedes_ids(ids)
  if(length(ids)>1) {
    res=pbapply::pbsapply(ids, choose_good_point, raw=raw, reroot=reroot, ...)
    return(t(res))
  }
  rawpt=tryCatch({
    n=with_aedes(fafbseg::read_l2skel(ids))[[1]]
    if(reroot) {
      # reroot onto the furthest endpoint from the root
      eps=endpoints(n)
      ng=as.ngraph(n, weights=T)
      # nb there should only be one rootpoint but just occasionally ...
      epdists=igraph::distances(ng, v = rootpoints(n)[1], to=eps)
      n=reroot(n, eps[which.max(epdists)])
    }
    n1=nat::simplify_neuron(n, n=1)
    bp1=branchpoints(n1)
    if(length(bp1)<1) {
      warning("Unable to extract key point for id: ", ids, ", so using root!")
      bp1=1L
    }
    pt=nat::xyzmatrix(n1)[bp1[1],]
    if(raw) with_aedes(fafbseg::flywire_nm2raw(pt)) else pt
  }, error=function(e) cbind(NA,NA,NA))
  rawpt
}

aedes_set_group <- function(ids, group=NULL, dry_run=TRUE) {
  ids=flywire_ids(ids)
  ii=flytable_list_selected(ids=ids, table = 'aedes_main', fields = c("_id", "serial_id", "root_id", "group"))
  if(!isTRUE(nrow(ii)==length(ids)))
    stop('unable to find all ids in flytable!')

  g=min(ii$serial_id, na.rm = T)
  if(is.na(g))
    stop("no valid serial_id")
  ii$group=g
  if(dry_run) g else flytable_update_rows(ii[c("_id", "group")], table = 'aedes_main')
}

segment_exterior_score <- function(x, m, offset=0, ...) {
  if(is.neuronlist(x)) {
    res=nlapply(x, segment_exterior_score, m=m, offset=offset, ...)
    res2=dplyr::bind_rows(unclass(res), .id='id')
    return(res2)
  }
  if(!inherits(m, 'mesh3d'))
    m=as.mesh3d(m)
  ex=nat::endpoints(x)
  sx=nat::as.seglist(x)
  endsegs=sapply(sx, function(s) any(s %in% ex))
  eps=sapply(sx[endsegs], function(s) intersect(s,ex)[1])
  df=data.frame(ep=rep(eps, lengths(sx[endsegs])), idx=unlist(sx[endsegs]))
  df$delta=nat::pointsinside(nat::xyzmatrix(x)[df$idx,,drop=F], surf = m, rval = 'dist')
  df
}

find_root_l2skel <- function(x, m, offset=0, rval=c('point', 'idx', 'neuron'), ...) {
  rval=match.arg(rval)
  if(is.neuronlist(x)) {
    res=nlapply(x, find_root_l2skel, m=m, offset=offset, rval=rval, ...)
    res2=dplyr::bind_rows(unclass(res), .id='id')
    return(res2)
  }

  ses=segment_exterior_score(x, m=m, ...)
  ses2=ses %>% group_by(ep) %>% summarise(n=n(), sd=sum(delta[delta<0])) %>% arrange(sd)
  rootidx=ses2$ep[1]
  if(rval=='idx')
    rootidx
  else if(rval=='point')
    xyzmatrix(x)[rootidx,,drop=F]
  else {
    reroot(x, idx = rootidx)
  }
}
