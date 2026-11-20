// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'FLACidal';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get retry => 'Réessayer';

  @override
  String get close => 'Fermer';

  @override
  String get ok => 'OK';

  @override
  String get apply => 'Appliquer';

  @override
  String get enable => 'Activer';

  @override
  String get later => 'Plus tard';

  @override
  String get configured => 'Configuré';

  @override
  String get notConfigured => 'Non configuré';

  @override
  String get coreErrorGeneric => 'Une erreur est survenue.';

  @override
  String get coreErrorNotInitialized =>
      'Le moteur de téléchargement n\'est pas encore prêt.';

  @override
  String coreErrorDetail(String message, String detail) {
    return '$message ($detail)';
  }

  @override
  String get extensionErrorInvalidId =>
      'L\'identifiant de l\'extension n\'est pas valide.';

  @override
  String get extensionErrorReservedId =>
      'Cet identifiant est réservé à une source intégrée.';

  @override
  String get extensionErrorInsecureUrl =>
      'L\'adresse de l\'extension doit utiliser HTTPS.';

  @override
  String get extensionErrorTooLarge =>
      'Le paquet de l\'extension est trop volumineux.';

  @override
  String get extensionErrorInvalidZip =>
      'Le paquet de l\'extension n\'est pas une archive valide.';

  @override
  String get extensionErrorInvalidManifest =>
      'Le manifeste de l\'extension n\'est pas valide.';

  @override
  String get extensionErrorNotFound => 'Cette extension n\'est pas installée.';

  @override
  String get extensionErrorInvalidAuthField =>
      'Un des champs de connexion n\'est pas accepté par l\'extension.';

  @override
  String get extensionErrorRegistry =>
      'Le registre d\'extensions n\'a pas pu être lu.';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get sectionDownload => 'Téléchargement';

  @override
  String get settingsQuality => 'Qualité';

  @override
  String get settingsDownloadFolder => 'Dossier de téléchargement';

  @override
  String get settingsPickFolder => 'Choisir un dossier de téléchargement';

  @override
  String get settingsOrganizeFolders => 'Organiser par dossiers';

  @override
  String get settingsOrganizeFoldersHint =>
      'Crée des sous-dossiers par artiste et album';

  @override
  String get settingsFolderStructure => 'Structure des dossiers';

  @override
  String get folderFlat => 'À plat';

  @override
  String get folderByArtistAlbum => 'Par artiste et album';

  @override
  String get folderByPlaylist => 'Par playlist';

  @override
  String get folderArtistSingles => 'Artiste + singles';

  @override
  String get settingsEmbedCover => 'Intégrer la pochette';

  @override
  String get settingsDownloadFormat => 'Format de téléchargement';

  @override
  String get settingsFirstArtistOnly => 'Premier artiste uniquement';

  @override
  String get settingsFirstArtistOnlyHint =>
      'N\'écrit que le premier artiste dans le tag artiste';

  @override
  String get settingsArtistSeparator => 'Séparateur d\'artistes';

  @override
  String get settingsArtistSeparatorHint =>
      'Placé entre les artistes dans le tag artiste';

  @override
  String get artistSeparatorInvalid => 'Saisissez de 1 à 8 caractères';

  @override
  String get sectionSources => 'Sources';

  @override
  String get settingsMusicSources => 'Sources musicales';

  @override
  String get settingsMusicSourcesHint => 'Configurer Tidal et Qobuz';

  @override
  String get settingsPreferredSource => 'Source préférée';

  @override
  String get sectionEndpoints => 'Points d’accès auto-hébergés';

  @override
  String endpointsTitle(String name) {
    return 'Points d’accès prioritaires $name';
  }

  @override
  String get endpointsPublicOnly => 'Pool public uniquement';

  @override
  String endpointsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count points d’accès auto-hébergés',
      one: '1 point d’accès auto-hébergé',
    );
    return '$_temp0';
  }

  @override
  String endpointsSaveFailed(String error) {
    return 'Impossible d\'enregistrer les points d’accès : $error';
  }

  @override
  String get settingsExtensions => 'Extensions';

  @override
  String get settingsExtensionsHint => 'Découvrir et ajouter des modules';

  @override
  String get settingsExtensionRepos => 'Dépôts d\'extensions';

  @override
  String get settingsExtensionReposHint =>
      'Ajouter vos propres sources d\'extensions';

  @override
  String get sectionHistory => 'Historique';

  @override
  String get settingsDownloadHistory => 'Historique des téléchargements';

  @override
  String get sectionAppearance => 'Apparence';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsFont => 'Police';

  @override
  String get fontSystemDefault => 'Police du système';

  @override
  String get settingsAccent => 'Couleur d\'accent';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageAuto => 'Automatique (langue de l\'appareil)';

  @override
  String get sectionAbout => 'À propos';

  @override
  String get settingsAppName => 'FLACidal Mobile';

  @override
  String get settingsExport => 'Exporter la configuration';

  @override
  String get settingsImport => 'Importer la configuration';

  @override
  String get settingsChooseExportLocation => 'Choisir l\'emplacement d\'export';

  @override
  String settingsConfigExported(String path) {
    return 'Configuration exportée vers $path';
  }

  @override
  String settingsExportFailed(String error) {
    return 'Échec de l\'export : $error';
  }

  @override
  String get settingsImportTitle => 'Importer la configuration';

  @override
  String get settingsImportWarning =>
      'L’import remplacera vos réglages actuels. Les identifiants Tidal, Soulseek et Qobuz devront être saisis à nouveau après l’import.';

  @override
  String get settingsImportAnyway => 'Importer quand même';

  @override
  String get settingsConfigImported => 'Configuration importée';

  @override
  String settingsImportFailed(String error) {
    return 'Échec de l\'import : $error';
  }

  @override
  String get repoManagerHint => 'https://...';

  @override
  String get sourcesTitle => 'Sources';

  @override
  String get sourcesPriority => 'Priorité des sources';

  @override
  String get sourcesAvailable => 'Sources disponibles';

  @override
  String get sourcesNone => 'Aucune source trouvée';

  @override
  String get sourcesPreferred => 'Source préférée';

  @override
  String get sourcesPrimary => 'Source principale';

  @override
  String get sourcesQualityFallback => 'Repli de qualité';

  @override
  String get sourcesQualityFallbackHint =>
      'Réessaie à une qualité inférieure quand la qualité demandée n\'est pas disponible';

  @override
  String get sourcesQobuzCredentials => 'Identifiants Qobuz';

  @override
  String get sourcesAppId => 'ID de l’application';

  @override
  String get sourcesAppSecret => 'Secret de l’application';

  @override
  String get sourcesAuthToken => 'Jeton d\'authentification';

  @override
  String get sourcesTestConnection => 'Tester la connexion';

  @override
  String get sourcesConnected => 'Connexion réussie';

  @override
  String sourcesConnectFailed(String error) {
    return 'Connexion impossible : $error';
  }

  @override
  String sourcesTestFailed(String error) {
    return 'Le test de connexion a échoué : $error';
  }

  @override
  String get sourcesQobuzUpdated => 'Identifiants Qobuz mis à jour';

  @override
  String get sourcesSoulseekCredentials => 'Identifiants Soulseek';

  @override
  String get sourcesSoulseekUpdated => 'Identifiants Soulseek mis à jour';

  @override
  String get sourcesUsername => 'Nom d\'utilisateur';

  @override
  String get sourcesPassword => 'Mot de passe';

  @override
  String sourcesLoadFailed(String error) {
    return 'Impossible de charger les sources : $error';
  }

  @override
  String sourcesSetPreferredFailed(String error) {
    return 'Impossible de définir la source préférée : $error';
  }

  @override
  String sourcesFallbackFailed(String error) {
    return 'Impossible de modifier le repli de qualité : $error';
  }

  @override
  String sourcesSaveCredentialsFailed(String error) {
    return 'Impossible d\'enregistrer les identifiants : $error';
  }

  @override
  String sourcesSaveOrderFailed(String error) {
    return 'Impossible d\'enregistrer l\'ordre des sources : $error';
  }

  @override
  String get extTitle => 'Extensions';

  @override
  String get extTabInstalled => 'Installées';

  @override
  String get extTabBrowse => 'Parcourir';

  @override
  String get extNoneInstalled => 'Rien d\'installé pour l\'instant';

  @override
  String get extNoneInstalledHint =>
      'Consultez le registre pour trouver des extensions';

  @override
  String get extNoneAvailable => 'Rien de disponible pour le moment';

  @override
  String get extRefresh => 'Actualiser';

  @override
  String get extSearchHint => 'Rechercher des extensions...';

  @override
  String get extCategoryAll => 'Toutes';

  @override
  String get extCategoryDownload => 'Téléchargement';

  @override
  String get extCategoryMetadata => 'Métadonnées';

  @override
  String get extCategoryLyrics => 'Paroles';

  @override
  String get extCategoryUtility => 'Utilitaires';

  @override
  String get extInstall => 'Installer';

  @override
  String get extUpdate => 'Mettre à jour';

  @override
  String get extInstalledChip => 'Installée';

  @override
  String extPermissions(String list) {
    return 'Autorisations : $list';
  }

  @override
  String get extSources => 'Sources';

  @override
  String get extAddSource => 'Ajouter une source';

  @override
  String get extAddSourceTitle => 'Ajouter une source d\'extensions';

  @override
  String get extRepoUrlLabel => 'URL du dépôt GitHub';

  @override
  String get extRepoUrlInvalid =>
      'Saisissez une adresse comme https://github.com/owner/repo';

  @override
  String get extAdd => 'Ajouter';

  @override
  String get extNoExtraSources => 'Aucune source supplémentaire configurée';

  @override
  String get extSourceAdded => 'Nouvelle source ajoutée';

  @override
  String extSourceAddFailed(String error) {
    return 'Impossible d\'ajouter la source : $error';
  }

  @override
  String extSourceRemoveFailed(String error) {
    return 'Impossible de retirer la source : $error';
  }

  @override
  String get extAdded => 'Extension ajoutée';

  @override
  String extInstallFailed(String error) {
    return 'Échec de l\'installation : $error';
  }

  @override
  String get extUninstallTitle => 'Désinstaller l\'extension';

  @override
  String extUninstallConfirm(String id) {
    return 'Retirer l\'extension « $id » ?';
  }

  @override
  String get extUninstall => 'Désinstaller';

  @override
  String extActionFailed(String error) {
    return 'Une erreur est survenue : $error';
  }

  @override
  String get extConfigure => 'Configurer';

  @override
  String extConfigureTitle(String name) {
    return 'Configurer $name';
  }

  @override
  String get extNothingToConfigure => 'Rien à configurer ici';

  @override
  String get extConfigUpdated => 'Configuration mise à jour';

  @override
  String extRegistryFailed(String error) {
    return 'Impossible de charger le registre : $error';
  }

  @override
  String extRegistrySourceFailed(String source, String error) {
    return 'Impossible de lire la source $source : $error';
  }

  @override
  String extEnableTitle(String name) {
    return 'Activer $name ?';
  }

  @override
  String get extEnableHosts => 'Cette extension peut contacter :';

  @override
  String get extEnableNoHosts => 'Aucun hôte réseau déclaré';

  @override
  String get extEnablePermissions => 'Autorisations';

  @override
  String get extEnableNoPermissions => 'Aucune déclarée';

  @override
  String librarySelected(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String get libraryCancelSelection => 'Annuler la sélection';

  @override
  String get libraryRename => 'Renommer';

  @override
  String get libraryAnalyze => 'Analyser';

  @override
  String get renameTitle => 'Renommer les fichiers';

  @override
  String get renameTemplate => 'Modèle';

  @override
  String get renameCustomTemplate => 'Modèle personnalisé';

  @override
  String get renamePreview => 'Aperçu';

  @override
  String renameApply(int count) {
    return 'Renommer $count fichier(s)';
  }

  @override
  String get renamePreviewFirst =>
      'Prévisualisez les nouveaux noms avant de renommer';

  @override
  String renamePreviewFailed(String error) {
    return 'Impossible de générer l\'aperçu : $error';
  }

  @override
  String renameFailed(String error) {
    return 'Échec du renommage : $error';
  }

  @override
  String renameDone(int ok, int failed) {
    return '$ok renommé(s), $failed en échec';
  }

  @override
  String renameRowError(String error) {
    return 'Renommage impossible : $error';
  }

  @override
  String get analyzerTitle => 'Analyse audio';

  @override
  String analyzerFailed(String error) {
    return 'Échec de l\'analyse : $error';
  }

  @override
  String get analyzerVerdict => 'Verdict';

  @override
  String get analyzerConfidence => 'Confiance';

  @override
  String get analyzerSampleRate => 'Fréquence d\'échantillonnage';

  @override
  String get analyzerBitDepth => 'Profondeur de bits';

  @override
  String get analyzerCutoff => 'Coupure du spectre';

  @override
  String get analyzerExpectedCutoff => 'Coupure attendue';

  @override
  String get analyzerBpm => 'Tempo';

  @override
  String get analyzerKey => 'Tonalité';

  @override
  String get analyzerDetails => 'Détails';

  @override
  String get analyzerVerdictLossless => 'Sans perte';

  @override
  String get analyzerVerdictLikelyUpscaled => 'Probablement suréchantillonné';

  @override
  String get analyzerVerdictUpscaled => 'Suréchantillonné';

  @override
  String analyzerHz(int value) {
    return '$value Hz';
  }

  @override
  String analyzerBits(int value) {
    return '$value bits';
  }

  @override
  String get updateRequiredTitle => 'Mise à jour requise';

  @override
  String updateRequiredBody(String current, int behind, String latest) {
    return 'Cette version ($current) a $behind versions de retard sur la dernière release ($latest). Mettez à jour pour continuer à utiliser l’application.';
  }

  @override
  String get updateNow => 'Mettre à jour';

  @override
  String get updateDownloading => 'Téléchargement...';

  @override
  String get updateDownloadingLong => 'Téléchargement de la mise à jour...';

  @override
  String updateMigrationBody(String latest) {
    return 'Cette mise à jour utilise une nouvelle clé de signature : elle ne peut pas s’installer par-dessus votre version actuelle. Exportez votre configuration (Paramètres > À propos > Exporter la configuration), désinstallez la bêta, puis installez la $latest.';
  }

  @override
  String get updateOpenRelease => 'Ouvrir la page de la release';

  @override
  String get navHome => 'Accueil';

  @override
  String get navSearch => 'Recherche';

  @override
  String get navQueue => 'File d\'attente';

  @override
  String get navLibrary => 'Bibliothèque';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get downloadingTitle => 'Téléchargement';

  @override
  String downloadedSoFar(int completed, int total) {
    return '$completed sur $total téléchargés';
  }

  @override
  String get trackPlay => 'Lecture';

  @override
  String get trackPause => 'Pause';

  @override
  String get trackDownload => 'Télécharger';

  @override
  String get trackDownloadQuality => 'Qualité de téléchargement';

  @override
  String get viewAll => 'Tout voir';

  @override
  String get historyTitle => 'Historique';

  @override
  String get historyClearTitle => 'Effacer l\'historique';

  @override
  String get historyClearBody =>
      'Cela supprime tout l\'historique de téléchargement, sans retour possible.';

  @override
  String get historyClear => 'Effacer';

  @override
  String get historyWipe => 'Vider l\'historique';

  @override
  String get historyEmpty => 'Rien de téléchargé pour le moment';

  @override
  String get queueTitle => 'File d\'attente';

  @override
  String get queueRetryFailed => 'Relancer les échecs';

  @override
  String get queueActive => 'Actifs';

  @override
  String get queueQueued => 'En attente';

  @override
  String get queueFailed => 'Échecs';

  @override
  String get queuePaused => 'EN PAUSE';

  @override
  String get queueEmpty => 'Aucun téléchargement en cours';

  @override
  String queueTrackFallback(int id) {
    return 'Piste $id';
  }

  @override
  String queueSpeedLeft(String speed, String remaining) {
    return '$speed, $remaining restants';
  }

  @override
  String errorGeneric(String error) {
    return 'Une erreur est survenue : $error';
  }

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pistes',
      one: '1 piste',
    );
    return '$_temp0';
  }

  @override
  String tracksQueued(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pistes en file',
      one: '1 piste en file',
    );
    return '$_temp0';
  }

  @override
  String titleQueued(String title) {
    return '$title ajouté à la file';
  }

  @override
  String get viewQueue => 'Voir la file';

  @override
  String downloadCount(int count) {
    return 'Télécharger $count';
  }

  @override
  String get delete => 'Supprimer';

  @override
  String get selectAll => 'Tout sélectionner';

  @override
  String get deselectAll => 'Tout désélectionner';

  @override
  String get homeResolveFailed =>
      'Impossible de résoudre cette URL vers une source prise en charge';

  @override
  String get homeImportCsv => 'Importer un CSV';

  @override
  String get homeUrlHint =>
      'Collez une URL Tidal, Qobuz, Deezer ou Bandcamp ici...';

  @override
  String get homePasteTooltip => 'Coller depuis le presse-papiers';

  @override
  String get homeFetch => 'Récupérer';

  @override
  String get homeGetStarted =>
      'Pour commencer, collez une URL Tidal, Qobuz, Deezer ou Bandcamp';

  @override
  String get searchHint => 'Rechercher...';

  @override
  String searchHintService(String service) {
    return 'Rechercher sur $service...';
  }

  @override
  String get searchSongsOnly => 'Titres uniquement';

  @override
  String get searchSortRelevance => 'Pertinence';

  @override
  String get searchSortDate => 'Date';

  @override
  String searchTabTracks(int count) {
    return 'Pistes ($count)';
  }

  @override
  String searchTabAlbums(int count) {
    return 'Albums ($count)';
  }

  @override
  String searchTabArtists(int count) {
    return 'Artistes ($count)';
  }

  @override
  String searchTabDeezer(int count) {
    return 'Deezer ($count)';
  }

  @override
  String get searchPrompt =>
      'Recherchez des pistes, des albums ou des artistes';

  @override
  String get searchDeezerPrompt =>
      'Cherchez sur Deezer pour trouver des résultats de partout';

  @override
  String get openInTidal => 'Ouvrir dans Tidal';

  @override
  String get share => 'Partager';

  @override
  String get deleteFilesTitle => 'Supprimer les fichiers';

  @override
  String deleteFilesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Supprimer les $count fichiers sélectionnés ?',
      one: 'Supprimer le fichier sélectionné ?',
    );
    return '$_temp0';
  }

  @override
  String discLabel(int number) {
    return 'Disque $number';
  }

  @override
  String get lyricsTitle => 'Paroles';

  @override
  String get lyricsMissingInput =>
      'Ni chemin de fichier ni informations de piste.';

  @override
  String get lyricsNoFilePath =>
      'Les paroles ne peuvent pas être intégrées sans chemin de fichier.';

  @override
  String get lyricsNothingToEmbed => 'Il n’y a rien à intégrer.';

  @override
  String get lyricsEmbedded => 'Paroles intégrées.';

  @override
  String lyricsEmbedFailed(String error) {
    return 'Échec de l\'intégration des paroles : $error';
  }

  @override
  String get lyricsInstrumental => 'Instrumental';

  @override
  String get lyricsEmbedTooltip => 'Intégrer les paroles dans le FLAC';

  @override
  String get lyricsTabSynced => 'Synchronisées';

  @override
  String get lyricsTabPlain => 'Texte brut';

  @override
  String get lyricsLooksInstrumental =>
      'Cette piste semble être instrumentale.';

  @override
  String get lyricsNotFound => 'Aucune parole trouvée pour cette piste.';

  @override
  String get lyricsNoSynced => 'Pas de paroles synchronisées.';

  @override
  String get lyricsNoPlain => 'Pas de paroles en texte brut.';

  @override
  String get metaTitle => 'Modifier les métadonnées';

  @override
  String get metaUpdated => 'Métadonnées mises à jour';

  @override
  String metaSavedCover(String path) {
    return 'Pochette enregistrée dans $path';
  }

  @override
  String metaSavedLyrics(String path) {
    return 'Paroles enregistrées dans $path';
  }

  @override
  String get metaNothingNew => 'Rien de nouveau à mettre à jour';

  @override
  String metaFieldsUpdated(String fields) {
    return 'Champs mis à jour : $fields';
  }

  @override
  String get metaExtractCover => 'Extraire la pochette';

  @override
  String get metaSaveLyrics => 'Enregistrer les paroles';

  @override
  String get metaReEnrich => 'Ré-enrichir';

  @override
  String get metaFieldTitle => 'Titre';

  @override
  String get metaFieldArtist => 'Artiste';

  @override
  String get metaFieldAlbum => 'Album';

  @override
  String get metaFieldAlbumArtist => 'Artiste de l\'album';

  @override
  String get metaFieldTrackNumber => 'N° de piste';

  @override
  String get metaFieldDiscNumber => 'N° de disque';

  @override
  String get metaFieldYear => 'Année';

  @override
  String get metaFieldGenre => 'Genre';

  @override
  String get metaFieldIsrc => 'ISRC';

  @override
  String get metaFieldLabel => 'Label';

  @override
  String get metaFieldCopyright => 'Droits d’auteur';

  @override
  String get metaFieldComposer => 'Compositeur';

  @override
  String get metaFieldComment => 'Commentaire';

  @override
  String get csvTitle => 'Importer un CSV';

  @override
  String get csvPick => 'Choisir un fichier CSV';

  @override
  String get csvColumns =>
      'Les fichiers CSV doivent contenir ces colonnes : Track Name, Artist Name(s), Album Name, ISRC. Le format d\'export de Spotify convient aussi.';

  @override
  String get csvChoose => 'Choisir un fichier';

  @override
  String get csvQuality => 'Qualité';

  @override
  String get csvMatch => 'Associer les pistes';

  @override
  String get csvNoMatch => 'Aucune piste associée, rien à mettre en file';

  @override
  String csvMatched(int matched, int total) {
    return '$matched / $total associées';
  }

  @override
  String csvQueue(int count) {
    return 'Mettre $count en file';
  }

  @override
  String get convertTitle => 'Convertir';

  @override
  String get convertFfmpegUnavailable => 'FFmpeg est indisponible';

  @override
  String get convertFfmpegBody =>
      'FFmpeg doit être installé sur cet appareil pour que la conversion fonctionne.';

  @override
  String convertFilesSelected(int count) {
    return '$count fichier(s) sélectionné(s)';
  }

  @override
  String convertMore(int count) {
    return '... et $count de plus';
  }

  @override
  String get convertOutputFormat => 'Format de sortie';

  @override
  String convertBitrate(int kbps) {
    return 'Débit : $kbps kbit/s';
  }

  @override
  String convertKbps(int kbps) {
    return '$kbps kbit/s';
  }

  @override
  String get convertDeleteOriginals => 'Supprimer les fichiers originaux';

  @override
  String get convertDeleteOriginalsHint =>
      'Supprime le FLAC d\'origine une fois la conversion terminée';

  @override
  String get convertConverting => 'Conversion...';

  @override
  String get convertDone => 'Conversion terminée';

  @override
  String convertFailed(String error) {
    return 'Échec de la conversion : $error';
  }

  @override
  String get libraryTitle => 'Bibliothèque';

  @override
  String libraryTitleCount(int count) {
    return 'Bibliothèque ($count)';
  }

  @override
  String get libraryTrackView => 'Vue par pistes';

  @override
  String get libraryAlbumView => 'Vue par albums';

  @override
  String get librarySort => 'Trier';

  @override
  String get librarySortName => 'Nom';

  @override
  String get librarySortDate => 'Date';

  @override
  String get librarySortSize => 'Taille';

  @override
  String get libraryFilterSource => 'Source';

  @override
  String get libraryFilterQuality => 'Qualité';

  @override
  String get libraryFilterFormat => 'Format';

  @override
  String get libraryFilterAll => 'Tous';

  @override
  String get libraryFilterUnknown => 'Inconnue';

  @override
  String get libraryFilterClear => 'Effacer';

  @override
  String get libraryEmpty => 'Vous n\'avez encore rien téléchargé';

  @override
  String get libraryEmptyHint =>
      'Rendez-vous sur l\'accueil pour télécharger des pistes';

  @override
  String get librarySearchHint => 'Rechercher dans votre bibliothèque...';

  @override
  String get libraryNothingMatches => 'Aucun résultat';

  @override
  String get libraryUnknownAlbum => 'Album inconnu';

  @override
  String get libraryMetadata => 'Métadonnées';

  @override
  String get librarySaveCover => 'Enregistrer la pochette';

  @override
  String get libraryDeleteTitle => 'Supprimer le fichier';

  @override
  String libraryDeleteBody(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String notifGrabbing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Récupération de $count pistes...',
      one: 'Récupération d’1 piste...',
    );
    return '$_temp0';
  }

  @override
  String notifProgress(int completed, int total) {
    return '$completed pistes sur $total téléchargées';
  }

  @override
  String get notifUpdateDownloading => 'Téléchargement de la mise à jour...';

  @override
  String notifUpdateProgress(int percent) {
    return 'Téléchargement de la mise à jour : $percent %';
  }
}
