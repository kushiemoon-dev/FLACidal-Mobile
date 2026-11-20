// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'FLACidal';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get close => 'Schließen';

  @override
  String get ok => 'OK';

  @override
  String get apply => 'Anwenden';

  @override
  String get enable => 'Aktivieren';

  @override
  String get later => 'Später';

  @override
  String get configured => 'Konfiguriert';

  @override
  String get notConfigured => 'Nicht konfiguriert';

  @override
  String get coreErrorGeneric => 'Etwas ist schiefgelaufen.';

  @override
  String get coreErrorNotInitialized =>
      'Die Download-Engine ist noch nicht bereit.';

  @override
  String coreErrorDetail(String message, String detail) {
    return '$message ($detail)';
  }

  @override
  String get extensionErrorInvalidId => 'Die Erweiterungs-ID ist ungültig.';

  @override
  String get extensionErrorReservedId =>
      'Diese Erweiterungs-ID ist für eine integrierte Quelle reserviert.';

  @override
  String get extensionErrorInsecureUrl =>
      'Die Adresse der Erweiterung muss HTTPS verwenden.';

  @override
  String get extensionErrorTooLarge => 'Das Erweiterungspaket ist zu groß.';

  @override
  String get extensionErrorInvalidZip =>
      'Das Erweiterungspaket ist kein gültiges Archiv.';

  @override
  String get extensionErrorInvalidManifest =>
      'Das Manifest der Erweiterung ist ungültig.';

  @override
  String get extensionErrorNotFound =>
      'Diese Erweiterung ist nicht installiert.';

  @override
  String get extensionErrorInvalidAuthField =>
      'Eines der Anmeldefelder wird von der Erweiterung nicht akzeptiert.';

  @override
  String get extensionErrorRegistry =>
      'Das Erweiterungsregister konnte nicht gelesen werden.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get sectionDownload => 'Download';

  @override
  String get settingsQuality => 'Qualität';

  @override
  String get settingsDownloadFolder => 'Download-Ordner';

  @override
  String get settingsPickFolder => 'Download-Ordner auswählen';

  @override
  String get settingsOrganizeFolders => 'Nach Ordnern organisieren';

  @override
  String get settingsOrganizeFoldersHint =>
      'Erstellt Unterordner nach Künstler und Album';

  @override
  String get settingsFolderStructure => 'Ordnerstruktur';

  @override
  String get folderFlat => 'Flach';

  @override
  String get folderByArtistAlbum => 'Nach Künstler und Album';

  @override
  String get folderByPlaylist => 'Nach Playlist';

  @override
  String get folderArtistSingles => 'Künstler + Singles';

  @override
  String get settingsEmbedCover => 'Cover einbetten';

  @override
  String get settingsDownloadFormat => 'Download-Format';

  @override
  String get settingsFirstArtistOnly => 'Nur erster Künstler';

  @override
  String get settingsFirstArtistOnlyHint =>
      'Schreibt nur den ersten Künstler ins Künstler-Tag';

  @override
  String get settingsArtistSeparator => 'Künstlertrenner';

  @override
  String get settingsArtistSeparatorHint =>
      'Steht im Künstler-Tag zwischen den Künstlern';

  @override
  String get artistSeparatorInvalid => 'Gib 1 bis 8 Zeichen ein';

  @override
  String get sectionSources => 'Quellen';

  @override
  String get settingsMusicSources => 'Musikquellen';

  @override
  String get settingsMusicSourcesHint => 'Tidal und Qobuz konfigurieren';

  @override
  String get settingsPreferredSource => 'Bevorzugte Quelle';

  @override
  String get sectionEndpoints => 'Selbst gehostete Endpunkte';

  @override
  String endpointsTitle(String name) {
    return '$name-Prioritätsendpunkte';
  }

  @override
  String get endpointsPublicOnly => 'Nur öffentlicher Pool';

  @override
  String endpointsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selbst gehostete Endpunkte',
      one: '1 selbst gehosteter Endpunkt',
    );
    return '$_temp0';
  }

  @override
  String endpointsSaveFailed(String error) {
    return 'Endpunkte konnten nicht gespeichert werden: $error';
  }

  @override
  String get settingsExtensions => 'Erweiterungen';

  @override
  String get settingsExtensionsHint => 'Plugins entdecken und hinzufügen';

  @override
  String get settingsExtensionRepos => 'Erweiterungs-Repositories';

  @override
  String get settingsExtensionReposHint =>
      'Eigene Erweiterungsquellen hinzufügen';

  @override
  String get sectionHistory => 'Verlauf';

  @override
  String get settingsDownloadHistory => 'Download-Verlauf';

  @override
  String get sectionAppearance => 'Darstellung';

  @override
  String get settingsTheme => 'Design';

  @override
  String get settingsFont => 'Schriftart';

  @override
  String get fontSystemDefault => 'Systemstandard';

  @override
  String get settingsAccent => 'Akzentfarbe';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get languageAuto => 'Automatisch (Gerätesprache)';

  @override
  String get sectionAbout => 'Über';

  @override
  String get settingsAppName => 'FLACidal Mobile';

  @override
  String get settingsExport => 'Konfiguration exportieren';

  @override
  String get settingsImport => 'Konfiguration importieren';

  @override
  String get settingsChooseExportLocation => 'Exportziel wählen';

  @override
  String settingsConfigExported(String path) {
    return 'Konfiguration nach $path exportiert';
  }

  @override
  String settingsExportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get settingsImportTitle => 'Konfiguration importieren';

  @override
  String get settingsImportWarning =>
      'Der Import ersetzt deine aktuellen Einstellungen. Die Zugangsdaten für Tidal, Soulseek und Qobuz müssen nach dem Import erneut eingegeben werden.';

  @override
  String get settingsImportAnyway => 'Trotzdem importieren';

  @override
  String get settingsConfigImported => 'Konfiguration importiert';

  @override
  String settingsImportFailed(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get repoManagerHint => 'https://...';

  @override
  String get sourcesTitle => 'Quellen';

  @override
  String get sourcesPriority => 'Quellenreihenfolge';

  @override
  String get sourcesAvailable => 'Verfügbare Quellen';

  @override
  String get sourcesNone => 'Keine Quellen gefunden';

  @override
  String get sourcesPreferred => 'Bevorzugte Quelle';

  @override
  String get sourcesPrimary => 'Hauptquelle';

  @override
  String get sourcesQualityFallback => 'Qualitäts-Fallback';

  @override
  String get sourcesQualityFallbackHint =>
      'Versucht es in niedrigerer Qualität, wenn die gewünschte nicht verfügbar ist';

  @override
  String get sourcesQobuzCredentials => 'Qobuz-Zugangsdaten';

  @override
  String get sourcesAppId => 'App-ID';

  @override
  String get sourcesAppSecret => 'App-Geheimnis';

  @override
  String get sourcesAuthToken => 'Auth-Token';

  @override
  String get sourcesTestConnection => 'Verbindung testen';

  @override
  String get sourcesConnected => 'Verbindung erfolgreich';

  @override
  String sourcesConnectFailed(String error) {
    return 'Verbindung fehlgeschlagen: $error';
  }

  @override
  String sourcesTestFailed(String error) {
    return 'Der Verbindungstest ist fehlgeschlagen: $error';
  }

  @override
  String get sourcesQobuzUpdated => 'Qobuz-Zugangsdaten aktualisiert';

  @override
  String get sourcesSoulseekCredentials => 'Soulseek-Zugangsdaten';

  @override
  String get sourcesSoulseekUpdated => 'Soulseek-Zugangsdaten aktualisiert';

  @override
  String get sourcesUsername => 'Benutzername';

  @override
  String get sourcesPassword => 'Passwort';

  @override
  String sourcesLoadFailed(String error) {
    return 'Quellen konnten nicht geladen werden: $error';
  }

  @override
  String sourcesSetPreferredFailed(String error) {
    return 'Bevorzugte Quelle konnte nicht gesetzt werden: $error';
  }

  @override
  String sourcesFallbackFailed(String error) {
    return 'Qualitäts-Fallback konnte nicht geändert werden: $error';
  }

  @override
  String sourcesSaveCredentialsFailed(String error) {
    return 'Zugangsdaten konnten nicht gespeichert werden: $error';
  }

  @override
  String sourcesSaveOrderFailed(String error) {
    return 'Quellenreihenfolge konnte nicht gespeichert werden: $error';
  }

  @override
  String get extTitle => 'Erweiterungen';

  @override
  String get extTabInstalled => 'Installiert';

  @override
  String get extTabBrowse => 'Durchsuchen';

  @override
  String get extNoneInstalled => 'Noch nichts installiert';

  @override
  String get extNoneInstalledHint => 'Im Register nach Erweiterungen suchen';

  @override
  String get extNoneAvailable => 'Derzeit nichts verfügbar';

  @override
  String get extRefresh => 'Aktualisieren';

  @override
  String get extSearchHint => 'Erweiterungen suchen...';

  @override
  String get extCategoryAll => 'Alle';

  @override
  String get extCategoryDownload => 'Download';

  @override
  String get extCategoryMetadata => 'Metadaten';

  @override
  String get extCategoryLyrics => 'Songtexte';

  @override
  String get extCategoryUtility => 'Werkzeuge';

  @override
  String get extInstall => 'Installieren';

  @override
  String get extUpdate => 'Aktualisieren';

  @override
  String get extInstalledChip => 'Installiert';

  @override
  String extPermissions(String list) {
    return 'Berechtigungen: $list';
  }

  @override
  String get extSources => 'Quellen';

  @override
  String get extAddSource => 'Quelle hinzufügen';

  @override
  String get extAddSourceTitle => 'Erweiterungsquelle hinzufügen';

  @override
  String get extRepoUrlLabel => 'GitHub-Repository-URL';

  @override
  String get extRepoUrlInvalid =>
      'Gib eine Adresse wie https://github.com/owner/repo ein';

  @override
  String get extAdd => 'Hinzufügen';

  @override
  String get extNoExtraSources => 'Keine zusätzlichen Quellen eingerichtet';

  @override
  String get extSourceAdded => 'Neue Quelle hinzugefügt';

  @override
  String extSourceAddFailed(String error) {
    return 'Quelle konnte nicht hinzugefügt werden: $error';
  }

  @override
  String extSourceRemoveFailed(String error) {
    return 'Quelle konnte nicht entfernt werden: $error';
  }

  @override
  String get extAdded => 'Erweiterung hinzugefügt';

  @override
  String extInstallFailed(String error) {
    return 'Installation fehlgeschlagen: $error';
  }

  @override
  String get extUninstallTitle => 'Erweiterung deinstallieren';

  @override
  String extUninstallConfirm(String id) {
    return 'Die Erweiterung „$id“ entfernen?';
  }

  @override
  String get extUninstall => 'Deinstallieren';

  @override
  String extActionFailed(String error) {
    return 'Etwas ist schiefgelaufen: $error';
  }

  @override
  String get extConfigure => 'Konfigurieren';

  @override
  String extConfigureTitle(String name) {
    return '$name konfigurieren';
  }

  @override
  String get extNothingToConfigure => 'Hier gibt es nichts zu konfigurieren';

  @override
  String get extConfigUpdated => 'Konfiguration aktualisiert';

  @override
  String extRegistryFailed(String error) {
    return 'Das Register konnte nicht geladen werden: $error';
  }

  @override
  String extRegistrySourceFailed(String source, String error) {
    return 'Die Quelle $source konnte nicht gelesen werden: $error';
  }

  @override
  String extEnableTitle(String name) {
    return '$name aktivieren?';
  }

  @override
  String get extEnableHosts => 'Diese Erweiterung kann kontaktieren:';

  @override
  String get extEnableNoHosts => 'Keine Netzwerk-Hosts angegeben';

  @override
  String get extEnablePermissions => 'Berechtigungen';

  @override
  String get extEnableNoPermissions => 'Keine angegeben';

  @override
  String librarySelected(int count) {
    return '$count ausgewählt';
  }

  @override
  String get libraryCancelSelection => 'Auswahl aufheben';

  @override
  String get libraryRename => 'Umbenennen';

  @override
  String get libraryAnalyze => 'Analysieren';

  @override
  String get renameTitle => 'Dateien umbenennen';

  @override
  String get renameTemplate => 'Vorlage';

  @override
  String get renameCustomTemplate => 'Eigene Vorlage';

  @override
  String get renamePreview => 'Vorschau';

  @override
  String renameApply(int count) {
    return '$count Datei(en) umbenennen';
  }

  @override
  String get renamePreviewFirst =>
      'Zeige die neuen Namen vor dem Umbenennen an';

  @override
  String renamePreviewFailed(String error) {
    return 'Die Vorschau konnte nicht erstellt werden: $error';
  }

  @override
  String renameFailed(String error) {
    return 'Umbenennen fehlgeschlagen: $error';
  }

  @override
  String renameDone(int ok, int failed) {
    return '$ok umbenannt, $failed fehlgeschlagen';
  }

  @override
  String renameRowError(String error) {
    return 'Umbenennen nicht möglich: $error';
  }

  @override
  String get analyzerTitle => 'Audioanalyse';

  @override
  String analyzerFailed(String error) {
    return 'Analyse fehlgeschlagen: $error';
  }

  @override
  String get analyzerVerdict => 'Ergebnis';

  @override
  String get analyzerConfidence => 'Konfidenz';

  @override
  String get analyzerSampleRate => 'Abtastrate';

  @override
  String get analyzerBitDepth => 'Bittiefe';

  @override
  String get analyzerCutoff => 'Spektrum-Grenze';

  @override
  String get analyzerExpectedCutoff => 'Erwartete Grenze';

  @override
  String get analyzerBpm => 'Tempo';

  @override
  String get analyzerKey => 'Tonart';

  @override
  String get analyzerDetails => 'Details';

  @override
  String get analyzerVerdictLossless => 'Verlustfrei';

  @override
  String get analyzerVerdictLikelyUpscaled => 'Wahrscheinlich hochgerechnet';

  @override
  String get analyzerVerdictUpscaled => 'Hochgerechnet';

  @override
  String analyzerHz(int value) {
    return '$value Hz';
  }

  @override
  String analyzerBits(int value) {
    return '$value Bit';
  }

  @override
  String get updateRequiredTitle => 'Update erforderlich';

  @override
  String updateRequiredBody(String current, int behind, String latest) {
    return 'Diese Version ($current) liegt $behind Versionen hinter der neuesten Version ($latest). Aktualisiere jetzt, um die App weiter zu nutzen.';
  }

  @override
  String get updateNow => 'Jetzt aktualisieren';

  @override
  String get updateDownloading => 'Wird heruntergeladen...';

  @override
  String get updateDownloadingLong => 'Update wird heruntergeladen...';

  @override
  String updateMigrationBody(String latest) {
    return 'Dieses Update verwendet einen neuen Signaturschlüssel und kann nicht über die aktuelle Version installiert werden. Exportiere deine Konfiguration (Einstellungen > Über > Konfiguration exportieren), deinstalliere die Beta und installiere dann $latest.';
  }

  @override
  String get updateOpenRelease => 'Release-Seite öffnen';

  @override
  String get navHome => 'Start';

  @override
  String get navSearch => 'Suche';

  @override
  String get navQueue => 'Warteschlange';

  @override
  String get navLibrary => 'Bibliothek';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get downloadingTitle => 'Download läuft';

  @override
  String downloadedSoFar(int completed, int total) {
    return '$completed von $total heruntergeladen';
  }

  @override
  String get trackPlay => 'Wiedergabe';

  @override
  String get trackPause => 'Pause';

  @override
  String get trackDownload => 'Herunterladen';

  @override
  String get trackDownloadQuality => 'Download-Qualität';

  @override
  String get viewAll => 'Alle anzeigen';

  @override
  String get historyTitle => 'Verlauf';

  @override
  String get historyClearTitle => 'Verlauf löschen';

  @override
  String get historyClearBody =>
      'Dadurch wird dein gesamter Download-Verlauf gelöscht, ohne Möglichkeit zur Wiederherstellung.';

  @override
  String get historyClear => 'Löschen';

  @override
  String get historyWipe => 'Verlauf leeren';

  @override
  String get historyEmpty => 'Noch nichts heruntergeladen';

  @override
  String get queueTitle => 'Warteschlange';

  @override
  String get queueRetryFailed => 'Fehlgeschlagene wiederholen';

  @override
  String get queueActive => 'Aktiv';

  @override
  String get queueQueued => 'Wartend';

  @override
  String get queueFailed => 'Fehlgeschlagen';

  @override
  String get queuePaused => 'PAUSIERT';

  @override
  String get queueEmpty => 'Gerade wird nichts heruntergeladen';

  @override
  String queueTrackFallback(int id) {
    return 'Titel $id';
  }

  @override
  String queueSpeedLeft(String speed, String remaining) {
    return '$speed, noch $remaining';
  }

  @override
  String errorGeneric(String error) {
    return 'Etwas ist schiefgelaufen: $error';
  }

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Titel',
      one: '1 Titel',
    );
    return '$_temp0';
  }

  @override
  String tracksQueued(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Titel eingereiht',
      one: '1 Titel eingereiht',
    );
    return '$_temp0';
  }

  @override
  String titleQueued(String title) {
    return '$title eingereiht';
  }

  @override
  String get viewQueue => 'Warteschlange anzeigen';

  @override
  String downloadCount(int count) {
    return '$count herunterladen';
  }

  @override
  String get delete => 'Löschen';

  @override
  String get selectAll => 'Alle auswählen';

  @override
  String get deselectAll => 'Alle abwählen';

  @override
  String get homeResolveFailed =>
      'Diese URL konnte keiner unterstützten Quelle zugeordnet werden';

  @override
  String get homeImportCsv => 'CSV importieren';

  @override
  String get homeUrlHint =>
      'Füge hier eine Tidal-, Qobuz-, Deezer- oder Bandcamp-URL ein...';

  @override
  String get homePasteTooltip => 'Aus der Zwischenablage einfügen';

  @override
  String get homeFetch => 'Abrufen';

  @override
  String get homeGetStarted =>
      'Füge zum Start eine Tidal-, Qobuz-, Deezer- oder Bandcamp-URL ein';

  @override
  String get searchHint => 'Suchen...';

  @override
  String searchHintService(String service) {
    return '$service durchsuchen...';
  }

  @override
  String get searchSongsOnly => 'Nur Titel';

  @override
  String get searchSortRelevance => 'Relevanz';

  @override
  String get searchSortDate => 'Datum';

  @override
  String searchTabTracks(int count) {
    return 'Titel ($count)';
  }

  @override
  String searchTabAlbums(int count) {
    return 'Alben ($count)';
  }

  @override
  String searchTabArtists(int count) {
    return 'Künstler ($count)';
  }

  @override
  String searchTabDeezer(int count) {
    return 'Deezer ($count)';
  }

  @override
  String get searchPrompt => 'Suche nach Titeln, Alben oder Künstlern';

  @override
  String get searchDeezerPrompt =>
      'Suche bei Deezer, um Ergebnisse von überall zu finden';

  @override
  String get openInTidal => 'In Tidal öffnen';

  @override
  String get share => 'Teilen';

  @override
  String get deleteFilesTitle => 'Dateien löschen';

  @override
  String deleteFilesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausgewählte Dateien entfernen?',
      one: 'Die ausgewählte Datei entfernen?',
    );
    return '$_temp0';
  }

  @override
  String discLabel(int number) {
    return 'Disc $number';
  }

  @override
  String get lyricsTitle => 'Songtext';

  @override
  String get lyricsMissingInput =>
      'Weder Dateipfad noch Titelinformationen vorhanden.';

  @override
  String get lyricsNoFilePath =>
      'Songtexte können ohne Dateipfad nicht eingebettet werden.';

  @override
  String get lyricsNothingToEmbed => 'Es gibt nichts einzubetten.';

  @override
  String get lyricsEmbedded => 'Songtext eingebettet.';

  @override
  String lyricsEmbedFailed(String error) {
    return 'Songtext konnte nicht eingebettet werden: $error';
  }

  @override
  String get lyricsInstrumental => 'Instrumental';

  @override
  String get lyricsEmbedTooltip => 'Songtext in die FLAC-Datei einbetten';

  @override
  String get lyricsTabSynced => 'Synchronisiert';

  @override
  String get lyricsTabPlain => 'Nur Text';

  @override
  String get lyricsLooksInstrumental =>
      'Dieser Titel scheint instrumental zu sein.';

  @override
  String get lyricsNotFound => 'Für diesen Titel wurde kein Songtext gefunden.';

  @override
  String get lyricsNoSynced => 'Keine synchronisierten Songtexte vorhanden.';

  @override
  String get lyricsNoPlain => 'Kein reiner Songtext vorhanden.';

  @override
  String get metaTitle => 'Metadaten bearbeiten';

  @override
  String get metaUpdated => 'Metadaten aktualisiert';

  @override
  String metaSavedCover(String path) {
    return 'Cover gespeichert unter $path';
  }

  @override
  String metaSavedLyrics(String path) {
    return 'Songtext gespeichert unter $path';
  }

  @override
  String get metaNothingNew => 'Nichts Neues zu aktualisieren';

  @override
  String metaFieldsUpdated(String fields) {
    return 'Aktualisierte Felder: $fields';
  }

  @override
  String get metaExtractCover => 'Cover extrahieren';

  @override
  String get metaSaveLyrics => 'Songtext speichern';

  @override
  String get metaReEnrich => 'Neu anreichern';

  @override
  String get metaFieldTitle => 'Titel';

  @override
  String get metaFieldArtist => 'Künstler';

  @override
  String get metaFieldAlbum => 'Album';

  @override
  String get metaFieldAlbumArtist => 'Albumkünstler';

  @override
  String get metaFieldTrackNumber => 'Titel-Nr.';

  @override
  String get metaFieldDiscNumber => 'Disc-Nr.';

  @override
  String get metaFieldYear => 'Jahr';

  @override
  String get metaFieldGenre => 'Genre';

  @override
  String get metaFieldIsrc => 'ISRC';

  @override
  String get metaFieldLabel => 'Label';

  @override
  String get metaFieldCopyright => 'Copyright';

  @override
  String get metaFieldComposer => 'Komponist';

  @override
  String get metaFieldComment => 'Kommentar';

  @override
  String get csvTitle => 'CSV importieren';

  @override
  String get csvPick => 'CSV-Datei auswählen';

  @override
  String get csvColumns =>
      'CSV-Dateien benötigen diese Spalten: Track Name, Artist Name(s), Album Name, ISRC. Das Exportformat von Spotify funktioniert ebenfalls.';

  @override
  String get csvChoose => 'Datei wählen';

  @override
  String get csvQuality => 'Qualität';

  @override
  String get csvMatch => 'Titel zuordnen';

  @override
  String get csvNoMatch => 'Keine Titel zugeordnet, nichts einzureihen';

  @override
  String csvMatched(int matched, int total) {
    return '$matched / $total zugeordnet';
  }

  @override
  String csvQueue(int count) {
    return '$count einreihen';
  }

  @override
  String get convertTitle => 'Konvertieren';

  @override
  String get convertFfmpegUnavailable => 'FFmpeg ist nicht verfügbar';

  @override
  String get convertFfmpegBody =>
      'FFmpeg muss auf diesem Gerät installiert sein, damit die Konvertierung funktioniert.';

  @override
  String convertFilesSelected(int count) {
    return '$count Datei(en) ausgewählt';
  }

  @override
  String convertMore(int count) {
    return '... und $count weitere';
  }

  @override
  String get convertOutputFormat => 'Ausgabeformat';

  @override
  String convertBitrate(int kbps) {
    return 'Bitrate: $kbps kbit/s';
  }

  @override
  String convertKbps(int kbps) {
    return '$kbps kbit/s';
  }

  @override
  String get convertDeleteOriginals => 'Originaldateien löschen';

  @override
  String get convertDeleteOriginalsHint =>
      'Löscht die ursprüngliche FLAC-Datei nach der Konvertierung';

  @override
  String get convertConverting => 'Wird konvertiert...';

  @override
  String get convertDone => 'Konvertierung abgeschlossen';

  @override
  String convertFailed(String error) {
    return 'Konvertierung fehlgeschlagen: $error';
  }

  @override
  String get libraryTitle => 'Bibliothek';

  @override
  String libraryTitleCount(int count) {
    return 'Bibliothek ($count)';
  }

  @override
  String get libraryTrackView => 'Titelansicht';

  @override
  String get libraryAlbumView => 'Albumansicht';

  @override
  String get librarySort => 'Sortieren';

  @override
  String get librarySortName => 'Name';

  @override
  String get librarySortDate => 'Datum';

  @override
  String get librarySortSize => 'Größe';

  @override
  String get libraryFilterSource => 'Quelle';

  @override
  String get libraryFilterQuality => 'Qualität';

  @override
  String get libraryFilterFormat => 'Format';

  @override
  String get libraryFilterAll => 'Alle';

  @override
  String get libraryFilterUnknown => 'Unbekannt';

  @override
  String get libraryFilterClear => 'Zurücksetzen';

  @override
  String get libraryEmpty => 'Du hast noch nichts heruntergeladen';

  @override
  String get libraryEmptyHint =>
      'Gehe zur Startseite, um Titel herunterzuladen';

  @override
  String get librarySearchHint => 'Bibliothek durchsuchen...';

  @override
  String get libraryNothingMatches => 'Keine Treffer';

  @override
  String get libraryUnknownAlbum => 'Unbekanntes Album';

  @override
  String get libraryMetadata => 'Metadaten';

  @override
  String get librarySaveCover => 'Cover speichern';

  @override
  String get libraryDeleteTitle => 'Datei löschen';

  @override
  String libraryDeleteBody(String name) {
    return '„$name“ entfernen?';
  }

  @override
  String notifGrabbing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Titel werden geladen...',
      one: '1 Titel wird geladen...',
    );
    return '$_temp0';
  }

  @override
  String notifProgress(int completed, int total) {
    return '$completed von $total Titeln heruntergeladen';
  }

  @override
  String get notifUpdateDownloading => 'Update wird heruntergeladen...';

  @override
  String notifUpdateProgress(int percent) {
    return 'Update wird heruntergeladen: $percent %';
  }
}
