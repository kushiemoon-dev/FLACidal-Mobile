// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FLACidal';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get apply => 'Apply';

  @override
  String get enable => 'Enable';

  @override
  String get later => 'Later';

  @override
  String get configured => 'Configured';

  @override
  String get notConfigured => 'Not configured';

  @override
  String get coreErrorGeneric => 'Something went wrong.';

  @override
  String get coreErrorNotInitialized => 'The download engine is not ready yet.';

  @override
  String coreErrorDetail(String message, String detail) {
    return '$message ($detail)';
  }

  @override
  String get extensionErrorInvalidId => 'The extension id is not valid.';

  @override
  String get extensionErrorReservedId =>
      'This extension id is reserved for a built-in source.';

  @override
  String get extensionErrorInsecureUrl =>
      'The extension address must use HTTPS.';

  @override
  String get extensionErrorTooLarge => 'The extension package is too large.';

  @override
  String get extensionErrorInvalidZip =>
      'The extension package is not a valid archive.';

  @override
  String get extensionErrorInvalidManifest =>
      'The extension manifest is not valid.';

  @override
  String get extensionErrorNotFound => 'This extension is not installed.';

  @override
  String get extensionErrorInvalidAuthField =>
      'One of the sign-in fields is not accepted by the extension.';

  @override
  String get extensionErrorRegistry =>
      'The extension registry could not be read.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionDownload => 'Download';

  @override
  String get settingsQuality => 'Quality';

  @override
  String get settingsDownloadFolder => 'Download folder';

  @override
  String get settingsPickFolder => 'Pick a download folder';

  @override
  String get settingsOrganizeFolders => 'Organize by folders';

  @override
  String get settingsOrganizeFoldersHint =>
      'Creates subfolders by Artist/Album';

  @override
  String get settingsFolderStructure => 'Folder structure';

  @override
  String get folderFlat => 'Flat';

  @override
  String get folderByArtistAlbum => 'By Artist/Album';

  @override
  String get folderByPlaylist => 'By Playlist';

  @override
  String get folderArtistSingles => 'Artist + Singles';

  @override
  String get settingsEmbedCover => 'Embed cover art';

  @override
  String get settingsDownloadFormat => 'Download format';

  @override
  String get settingsFirstArtistOnly => 'First artist only';

  @override
  String get settingsFirstArtistOnlyHint =>
      'Write only the first artist in the artist tag';

  @override
  String get settingsArtistSeparator => 'Artist separator';

  @override
  String get settingsArtistSeparatorHint =>
      'Used between artists in the artist tag';

  @override
  String get artistSeparatorInvalid => 'Enter 1 to 8 characters';

  @override
  String get sectionSources => 'Sources';

  @override
  String get settingsMusicSources => 'Music sources';

  @override
  String get settingsMusicSourcesHint => 'Configure Tidal and Qobuz';

  @override
  String get settingsPreferredSource => 'Preferred source';

  @override
  String get sectionEndpoints => 'Self-hosted endpoints';

  @override
  String endpointsTitle(String name) {
    return '$name priority endpoints';
  }

  @override
  String get endpointsPublicOnly => 'Public pool only';

  @override
  String endpointsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count self-hosted endpoints',
      one: '1 self-hosted endpoint',
    );
    return '$_temp0';
  }

  @override
  String endpointsSaveFailed(String error) {
    return 'Could not save endpoints: $error';
  }

  @override
  String get settingsExtensions => 'Extensions';

  @override
  String get settingsExtensionsHint => 'Discover and add plugins';

  @override
  String get settingsExtensionRepos => 'Extension repositories';

  @override
  String get settingsExtensionReposHint => 'Add your own extension sources';

  @override
  String get sectionHistory => 'History';

  @override
  String get settingsDownloadHistory => 'Download history';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsFont => 'Font';

  @override
  String get fontSystemDefault => 'System default';

  @override
  String get settingsAccent => 'Accent color';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageAuto => 'Automatic (device language)';

  @override
  String get sectionAbout => 'About';

  @override
  String get settingsAppName => 'FLACidal Mobile';

  @override
  String get settingsExport => 'Export config';

  @override
  String get settingsImport => 'Import config';

  @override
  String get settingsChooseExportLocation => 'Choose export location';

  @override
  String settingsConfigExported(String path) {
    return 'Config exported to $path';
  }

  @override
  String settingsExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get settingsImportTitle => 'Import config';

  @override
  String get settingsImportWarning =>
      'Importing will replace your current settings. Tidal, Soulseek, and Qobuz credentials will need to be re-entered after import.';

  @override
  String get settingsImportAnyway => 'Import anyway';

  @override
  String get settingsConfigImported => 'Config imported';

  @override
  String settingsImportFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get repoManagerHint => 'https://...';

  @override
  String get sourcesTitle => 'Sources';

  @override
  String get sourcesPriority => 'Source priority';

  @override
  String get sourcesAvailable => 'Available sources';

  @override
  String get sourcesNone => 'No sources found';

  @override
  String get sourcesPreferred => 'Preferred source';

  @override
  String get sourcesPrimary => 'Primary source';

  @override
  String get sourcesQualityFallback => 'Quality fallback';

  @override
  String get sourcesQualityFallbackHint =>
      'Retry at a lower quality when the requested one is unavailable';

  @override
  String get sourcesQobuzCredentials => 'Qobuz credentials';

  @override
  String get sourcesAppId => 'App ID';

  @override
  String get sourcesAppSecret => 'App secret';

  @override
  String get sourcesAuthToken => 'Auth token';

  @override
  String get sourcesTestConnection => 'Test connection';

  @override
  String get sourcesConnected => 'Connected successfully';

  @override
  String sourcesConnectFailed(String error) {
    return 'Could not connect: $error';
  }

  @override
  String sourcesTestFailed(String error) {
    return 'The connection test failed: $error';
  }

  @override
  String get sourcesQobuzUpdated => 'Qobuz credentials updated';

  @override
  String get sourcesSoulseekCredentials => 'Soulseek credentials';

  @override
  String get sourcesSoulseekUpdated => 'Soulseek credentials updated';

  @override
  String get sourcesUsername => 'Username';

  @override
  String get sourcesPassword => 'Password';

  @override
  String sourcesLoadFailed(String error) {
    return 'Could not load sources: $error';
  }

  @override
  String sourcesSetPreferredFailed(String error) {
    return 'Could not set the preferred source: $error';
  }

  @override
  String sourcesFallbackFailed(String error) {
    return 'Could not update the quality fallback: $error';
  }

  @override
  String sourcesSaveCredentialsFailed(String error) {
    return 'Could not save credentials: $error';
  }

  @override
  String sourcesSaveOrderFailed(String error) {
    return 'Could not save the source order: $error';
  }

  @override
  String get extTitle => 'Extensions';

  @override
  String get extTabInstalled => 'Installed';

  @override
  String get extTabBrowse => 'Browse';

  @override
  String get extNoneInstalled => 'Nothing installed yet';

  @override
  String get extNoneInstalledHint => 'Check the registry to find extensions';

  @override
  String get extNoneAvailable => 'Nothing available right now';

  @override
  String get extRefresh => 'Refresh';

  @override
  String get extSearchHint => 'Find extensions...';

  @override
  String get extCategoryAll => 'All';

  @override
  String get extCategoryDownload => 'Download';

  @override
  String get extCategoryMetadata => 'Metadata';

  @override
  String get extCategoryLyrics => 'Lyrics';

  @override
  String get extCategoryUtility => 'Utility';

  @override
  String get extInstall => 'Install';

  @override
  String get extUpdate => 'Update';

  @override
  String get extInstalledChip => 'Installed';

  @override
  String extPermissions(String list) {
    return 'Permissions: $list';
  }

  @override
  String get extSources => 'Sources';

  @override
  String get extAddSource => 'Add source';

  @override
  String get extAddSourceTitle => 'Add extension source';

  @override
  String get extRepoUrlLabel => 'GitHub repository URL';

  @override
  String get extRepoUrlInvalid =>
      'Enter an address like https://github.com/owner/repo';

  @override
  String get extAdd => 'Add';

  @override
  String get extNoExtraSources => 'No extra sources set up';

  @override
  String get extSourceAdded => 'New source added';

  @override
  String extSourceAddFailed(String error) {
    return 'Could not add the source: $error';
  }

  @override
  String extSourceRemoveFailed(String error) {
    return 'Could not remove the source: $error';
  }

  @override
  String get extAdded => 'Extension added';

  @override
  String extInstallFailed(String error) {
    return 'Installation failed: $error';
  }

  @override
  String get extUninstallTitle => 'Uninstall extension';

  @override
  String extUninstallConfirm(String id) {
    return 'Remove the \"$id\" extension?';
  }

  @override
  String get extUninstall => 'Uninstall';

  @override
  String extActionFailed(String error) {
    return 'Something went wrong: $error';
  }

  @override
  String get extConfigure => 'Configure';

  @override
  String extConfigureTitle(String name) {
    return 'Configure $name';
  }

  @override
  String get extNothingToConfigure => 'Nothing to configure here';

  @override
  String get extConfigUpdated => 'Configuration updated';

  @override
  String extRegistryFailed(String error) {
    return 'Unable to load the registry: $error';
  }

  @override
  String extRegistrySourceFailed(String source, String error) {
    return 'Could not read the source $source: $error';
  }

  @override
  String extEnableTitle(String name) {
    return 'Enable $name?';
  }

  @override
  String get extEnableHosts => 'This extension can contact:';

  @override
  String get extEnableNoHosts => 'No network hosts declared';

  @override
  String get extEnablePermissions => 'Permissions';

  @override
  String get extEnableNoPermissions => 'None declared';

  @override
  String librarySelected(int count) {
    return '$count selected';
  }

  @override
  String get libraryCancelSelection => 'Cancel selection';

  @override
  String get libraryRename => 'Rename';

  @override
  String get libraryAnalyze => 'Analyze';

  @override
  String get renameTitle => 'Rename files';

  @override
  String get renameTemplate => 'Template';

  @override
  String get renameCustomTemplate => 'Custom template';

  @override
  String get renamePreview => 'Preview';

  @override
  String renameApply(int count) {
    return 'Rename $count file(s)';
  }

  @override
  String get renamePreviewFirst => 'Preview the new names before renaming';

  @override
  String renamePreviewFailed(String error) {
    return 'Could not build the preview: $error';
  }

  @override
  String renameFailed(String error) {
    return 'Renaming failed: $error';
  }

  @override
  String renameDone(int ok, int failed) {
    return '$ok renamed, $failed failed';
  }

  @override
  String renameRowError(String error) {
    return 'Cannot rename: $error';
  }

  @override
  String get analyzerTitle => 'Audio analysis';

  @override
  String analyzerFailed(String error) {
    return 'Analysis failed: $error';
  }

  @override
  String get analyzerVerdict => 'Verdict';

  @override
  String get analyzerConfidence => 'Confidence';

  @override
  String get analyzerSampleRate => 'Sample rate';

  @override
  String get analyzerBitDepth => 'Bit depth';

  @override
  String get analyzerCutoff => 'Spectrum cutoff';

  @override
  String get analyzerExpectedCutoff => 'Expected cutoff';

  @override
  String get analyzerBpm => 'Tempo';

  @override
  String get analyzerKey => 'Key';

  @override
  String get analyzerDetails => 'Details';

  @override
  String get analyzerVerdictLossless => 'Lossless';

  @override
  String get analyzerVerdictLikelyUpscaled => 'Likely upscaled';

  @override
  String get analyzerVerdictUpscaled => 'Upscaled';

  @override
  String analyzerHz(int value) {
    return '$value Hz';
  }

  @override
  String analyzerBits(int value) {
    return '$value bit';
  }

  @override
  String get updateRequiredTitle => 'Update required';

  @override
  String updateRequiredBody(String current, int behind, String latest) {
    return 'This version ($current) is $behind versions behind the latest release ($latest). Update now to keep using the app.';
  }

  @override
  String get updateNow => 'Update now';

  @override
  String get updateDownloading => 'Downloading...';

  @override
  String get updateDownloadingLong => 'Downloading update...';

  @override
  String updateMigrationBody(String latest) {
    return 'This update uses a new signing key, so it cannot be installed over your current version. Export your configuration (Settings > About > Export config), uninstall the beta, then install $latest.';
  }

  @override
  String get updateOpenRelease => 'Open the release page';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navQueue => 'Queue';

  @override
  String get navLibrary => 'Library';

  @override
  String get navSettings => 'Settings';

  @override
  String get downloadingTitle => 'Downloading';

  @override
  String downloadedSoFar(int completed, int total) {
    return '$completed of $total downloaded so far';
  }

  @override
  String get trackPlay => 'Play';

  @override
  String get trackPause => 'Pause';

  @override
  String get trackDownload => 'Download';

  @override
  String get trackDownloadQuality => 'Download quality';

  @override
  String get viewAll => 'View all';

  @override
  String get historyTitle => 'History';

  @override
  String get historyClearTitle => 'Clear history';

  @override
  String get historyClearBody =>
      'This removes your entire download history; there is no going back.';

  @override
  String get historyClear => 'Clear';

  @override
  String get historyWipe => 'Wipe history';

  @override
  String get historyEmpty => 'Nothing downloaded yet';

  @override
  String get queueTitle => 'Queue';

  @override
  String get queueRetryFailed => 'Retry failed';

  @override
  String get queueActive => 'Active';

  @override
  String get queueQueued => 'Queued';

  @override
  String get queueFailed => 'Failed';

  @override
  String get queuePaused => 'PAUSED';

  @override
  String get queueEmpty => 'Nothing is downloading right now';

  @override
  String queueTrackFallback(int id) {
    return 'Track $id';
  }

  @override
  String queueSpeedLeft(String speed, String remaining) {
    return '$speed, $remaining left';
  }

  @override
  String errorGeneric(String error) {
    return 'Something went wrong: $error';
  }

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks',
      one: '1 track',
    );
    return '$_temp0';
  }

  @override
  String tracksQueued(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks queued',
      one: '1 track queued',
    );
    return '$_temp0';
  }

  @override
  String titleQueued(String title) {
    return '$title queued';
  }

  @override
  String get viewQueue => 'View queue';

  @override
  String downloadCount(int count) {
    return 'Download $count';
  }

  @override
  String get delete => 'Delete';

  @override
  String get selectAll => 'Select all';

  @override
  String get deselectAll => 'Deselect all';

  @override
  String get homeResolveFailed =>
      'Unable to resolve that URL to a supported source';

  @override
  String get homeImportCsv => 'Import CSV';

  @override
  String get homeUrlHint =>
      'Drop a Tidal, Qobuz, Deezer, or Bandcamp URL here...';

  @override
  String get homePasteTooltip => 'Fill in from clipboard';

  @override
  String get homeFetch => 'Fetch';

  @override
  String get homeGetStarted =>
      'Get started by pasting a Tidal, Qobuz, Deezer, or Bandcamp URL';

  @override
  String get searchHint => 'Search...';

  @override
  String searchHintService(String service) {
    return 'Search $service...';
  }

  @override
  String get searchSongsOnly => 'Songs only';

  @override
  String get searchSortRelevance => 'Relevance';

  @override
  String get searchSortDate => 'Date';

  @override
  String searchTabTracks(int count) {
    return 'Tracks ($count)';
  }

  @override
  String searchTabAlbums(int count) {
    return 'Albums ($count)';
  }

  @override
  String searchTabArtists(int count) {
    return 'Artists ($count)';
  }

  @override
  String searchTabDeezer(int count) {
    return 'Deezer ($count)';
  }

  @override
  String get searchPrompt => 'Look up tracks, albums, or artists';

  @override
  String get searchDeezerPrompt =>
      'Search Deezer to find results from anywhere';

  @override
  String get openInTidal => 'Open in Tidal';

  @override
  String get share => 'Share';

  @override
  String get deleteFilesTitle => 'Delete files';

  @override
  String deleteFilesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Remove $count selected files?',
      one: 'Remove the selected file?',
    );
    return '$_temp0';
  }

  @override
  String discLabel(int number) {
    return 'Disc $number';
  }

  @override
  String get lyricsTitle => 'Lyrics';

  @override
  String get lyricsMissingInput => 'Missing both a file path and track info.';

  @override
  String get lyricsNoFilePath =>
      'Lyrics can\'t be embedded without a file path.';

  @override
  String get lyricsNothingToEmbed => 'There\'s nothing to embed.';

  @override
  String get lyricsEmbedded => 'Lyrics embedded.';

  @override
  String lyricsEmbedFailed(String error) {
    return 'Failed to embed lyrics: $error';
  }

  @override
  String get lyricsInstrumental => 'Instrumental';

  @override
  String get lyricsEmbedTooltip => 'Embed lyrics into the FLAC';

  @override
  String get lyricsTabSynced => 'Synced';

  @override
  String get lyricsTabPlain => 'Plain';

  @override
  String get lyricsLooksInstrumental => 'This one looks to be instrumental.';

  @override
  String get lyricsNotFound => 'Couldn\'t find lyrics for this track.';

  @override
  String get lyricsNoSynced => 'No synced lyrics on hand.';

  @override
  String get lyricsNoPlain => 'No plain lyrics on hand.';

  @override
  String get metaTitle => 'Edit metadata';

  @override
  String get metaUpdated => 'Metadata updated';

  @override
  String metaSavedCover(String path) {
    return 'Saved cover art to $path';
  }

  @override
  String metaSavedLyrics(String path) {
    return 'Saved lyrics to $path';
  }

  @override
  String get metaNothingNew => 'Nothing new to update';

  @override
  String metaFieldsUpdated(String fields) {
    return 'Fields updated: $fields';
  }

  @override
  String get metaExtractCover => 'Extract cover art';

  @override
  String get metaSaveLyrics => 'Save lyrics';

  @override
  String get metaReEnrich => 'Re-enrich';

  @override
  String get metaFieldTitle => 'Title';

  @override
  String get metaFieldArtist => 'Artist';

  @override
  String get metaFieldAlbum => 'Album';

  @override
  String get metaFieldAlbumArtist => 'Album artist';

  @override
  String get metaFieldTrackNumber => 'Track #';

  @override
  String get metaFieldDiscNumber => 'Disc #';

  @override
  String get metaFieldYear => 'Year';

  @override
  String get metaFieldGenre => 'Genre';

  @override
  String get metaFieldIsrc => 'ISRC';

  @override
  String get metaFieldLabel => 'Label';

  @override
  String get metaFieldCopyright => 'Copyright';

  @override
  String get metaFieldComposer => 'Composer';

  @override
  String get metaFieldComment => 'Comment';

  @override
  String get csvTitle => 'Import CSV';

  @override
  String get csvPick => 'Pick a CSV file';

  @override
  String get csvColumns =>
      'CSV files need these columns: Track Name, Artist Name(s), Album Name, ISRC. Spotify\'s export format works too.';

  @override
  String get csvChoose => 'Choose file';

  @override
  String get csvQuality => 'Quality';

  @override
  String get csvMatch => 'Match tracks';

  @override
  String get csvNoMatch => 'No tracks matched, nothing to queue';

  @override
  String csvMatched(int matched, int total) {
    return '$matched / $total matched';
  }

  @override
  String csvQueue(int count) {
    return 'Queue $count';
  }

  @override
  String get convertTitle => 'Convert';

  @override
  String get convertFfmpegUnavailable => 'FFmpeg is unavailable';

  @override
  String get convertFfmpegBody =>
      'FFmpeg needs to be installed on this device for format conversion to work.';

  @override
  String convertFilesSelected(int count) {
    return '$count file(s) selected';
  }

  @override
  String convertMore(int count) {
    return '... and $count more';
  }

  @override
  String get convertOutputFormat => 'Output format';

  @override
  String convertBitrate(int kbps) {
    return 'Bitrate: $kbps kbps';
  }

  @override
  String convertKbps(int kbps) {
    return '$kbps kbps';
  }

  @override
  String get convertDeleteOriginals => 'Delete original files';

  @override
  String get convertDeleteOriginalsHint =>
      'Deletes the original FLAC once conversion finishes';

  @override
  String get convertConverting => 'Converting...';

  @override
  String get convertDone => 'Conversion finished';

  @override
  String convertFailed(String error) {
    return 'Conversion failed: $error';
  }

  @override
  String get libraryTitle => 'Library';

  @override
  String libraryTitleCount(int count) {
    return 'Library ($count)';
  }

  @override
  String get libraryTrackView => 'Track view';

  @override
  String get libraryAlbumView => 'Album view';

  @override
  String get librarySort => 'Sort';

  @override
  String get librarySortName => 'Name';

  @override
  String get librarySortDate => 'Date';

  @override
  String get librarySortSize => 'Size';

  @override
  String get libraryFilterSource => 'Source';

  @override
  String get libraryFilterQuality => 'Quality';

  @override
  String get libraryFilterFormat => 'Format';

  @override
  String get libraryFilterAll => 'All';

  @override
  String get libraryFilterUnknown => 'Unknown';

  @override
  String get libraryFilterClear => 'Clear';

  @override
  String get libraryEmpty => 'You haven\'t downloaded anything yet';

  @override
  String get libraryEmptyHint =>
      'Head to the Home page to download some tracks';

  @override
  String get librarySearchHint => 'Search your library...';

  @override
  String get libraryNothingMatches => 'Nothing matches';

  @override
  String get libraryUnknownAlbum => 'Unknown album';

  @override
  String get libraryMetadata => 'Metadata';

  @override
  String get librarySaveCover => 'Save cover art';

  @override
  String get libraryDeleteTitle => 'Delete file';

  @override
  String libraryDeleteBody(String name) {
    return 'Remove \"$name\"?';
  }

  @override
  String notifGrabbing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Grabbing $count tracks...',
      one: 'Grabbing 1 track...',
    );
    return '$_temp0';
  }

  @override
  String notifProgress(int completed, int total) {
    return '$completed of $total tracks downloaded';
  }

  @override
  String get notifUpdateDownloading => 'Downloading update...';

  @override
  String notifUpdateProgress(int percent) {
    return 'Downloading update: $percent%';
  }
}
