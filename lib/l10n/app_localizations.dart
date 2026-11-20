import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FLACidal'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @configured.
  ///
  /// In en, this message translates to:
  /// **'Configured'**
  String get configured;

  /// No description provided for @notConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get notConfigured;

  /// No description provided for @coreErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get coreErrorGeneric;

  /// No description provided for @coreErrorNotInitialized.
  ///
  /// In en, this message translates to:
  /// **'The download engine is not ready yet.'**
  String get coreErrorNotInitialized;

  /// No description provided for @coreErrorDetail.
  ///
  /// In en, this message translates to:
  /// **'{message} ({detail})'**
  String coreErrorDetail(String message, String detail);

  /// No description provided for @extensionErrorInvalidId.
  ///
  /// In en, this message translates to:
  /// **'The extension id is not valid.'**
  String get extensionErrorInvalidId;

  /// No description provided for @extensionErrorReservedId.
  ///
  /// In en, this message translates to:
  /// **'This extension id is reserved for a built-in source.'**
  String get extensionErrorReservedId;

  /// No description provided for @extensionErrorInsecureUrl.
  ///
  /// In en, this message translates to:
  /// **'The extension address must use HTTPS.'**
  String get extensionErrorInsecureUrl;

  /// No description provided for @extensionErrorTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The extension package is too large.'**
  String get extensionErrorTooLarge;

  /// No description provided for @extensionErrorInvalidZip.
  ///
  /// In en, this message translates to:
  /// **'The extension package is not a valid archive.'**
  String get extensionErrorInvalidZip;

  /// No description provided for @extensionErrorInvalidManifest.
  ///
  /// In en, this message translates to:
  /// **'The extension manifest is not valid.'**
  String get extensionErrorInvalidManifest;

  /// No description provided for @extensionErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'This extension is not installed.'**
  String get extensionErrorNotFound;

  /// No description provided for @extensionErrorInvalidAuthField.
  ///
  /// In en, this message translates to:
  /// **'One of the sign-in fields is not accepted by the extension.'**
  String get extensionErrorInvalidAuthField;

  /// No description provided for @extensionErrorRegistry.
  ///
  /// In en, this message translates to:
  /// **'The extension registry could not be read.'**
  String get extensionErrorRegistry;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sectionDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get sectionDownload;

  /// No description provided for @settingsQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get settingsQuality;

  /// No description provided for @settingsDownloadFolder.
  ///
  /// In en, this message translates to:
  /// **'Download folder'**
  String get settingsDownloadFolder;

  /// No description provided for @settingsPickFolder.
  ///
  /// In en, this message translates to:
  /// **'Pick a download folder'**
  String get settingsPickFolder;

  /// No description provided for @settingsOrganizeFolders.
  ///
  /// In en, this message translates to:
  /// **'Organize by folders'**
  String get settingsOrganizeFolders;

  /// No description provided for @settingsOrganizeFoldersHint.
  ///
  /// In en, this message translates to:
  /// **'Creates subfolders by Artist/Album'**
  String get settingsOrganizeFoldersHint;

  /// No description provided for @settingsFolderStructure.
  ///
  /// In en, this message translates to:
  /// **'Folder structure'**
  String get settingsFolderStructure;

  /// No description provided for @folderFlat.
  ///
  /// In en, this message translates to:
  /// **'Flat'**
  String get folderFlat;

  /// No description provided for @folderByArtistAlbum.
  ///
  /// In en, this message translates to:
  /// **'By Artist/Album'**
  String get folderByArtistAlbum;

  /// No description provided for @folderByPlaylist.
  ///
  /// In en, this message translates to:
  /// **'By Playlist'**
  String get folderByPlaylist;

  /// No description provided for @folderArtistSingles.
  ///
  /// In en, this message translates to:
  /// **'Artist + Singles'**
  String get folderArtistSingles;

  /// No description provided for @settingsEmbedCover.
  ///
  /// In en, this message translates to:
  /// **'Embed cover art'**
  String get settingsEmbedCover;

  /// No description provided for @settingsDownloadFormat.
  ///
  /// In en, this message translates to:
  /// **'Download format'**
  String get settingsDownloadFormat;

  /// No description provided for @settingsFirstArtistOnly.
  ///
  /// In en, this message translates to:
  /// **'First artist only'**
  String get settingsFirstArtistOnly;

  /// No description provided for @settingsFirstArtistOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'Write only the first artist in the artist tag'**
  String get settingsFirstArtistOnlyHint;

  /// No description provided for @settingsArtistSeparator.
  ///
  /// In en, this message translates to:
  /// **'Artist separator'**
  String get settingsArtistSeparator;

  /// No description provided for @settingsArtistSeparatorHint.
  ///
  /// In en, this message translates to:
  /// **'Used between artists in the artist tag'**
  String get settingsArtistSeparatorHint;

  /// No description provided for @artistSeparatorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter 1 to 8 characters'**
  String get artistSeparatorInvalid;

  /// No description provided for @sectionSources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get sectionSources;

  /// No description provided for @settingsMusicSources.
  ///
  /// In en, this message translates to:
  /// **'Music sources'**
  String get settingsMusicSources;

  /// No description provided for @settingsMusicSourcesHint.
  ///
  /// In en, this message translates to:
  /// **'Configure Tidal and Qobuz'**
  String get settingsMusicSourcesHint;

  /// No description provided for @settingsPreferredSource.
  ///
  /// In en, this message translates to:
  /// **'Preferred source'**
  String get settingsPreferredSource;

  /// No description provided for @sectionEndpoints.
  ///
  /// In en, this message translates to:
  /// **'Self-hosted endpoints'**
  String get sectionEndpoints;

  /// No description provided for @endpointsTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} priority endpoints'**
  String endpointsTitle(String name);

  /// No description provided for @endpointsPublicOnly.
  ///
  /// In en, this message translates to:
  /// **'Public pool only'**
  String get endpointsPublicOnly;

  /// No description provided for @endpointsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 self-hosted endpoint} other{{count} self-hosted endpoints}}'**
  String endpointsCount(int count);

  /// No description provided for @endpointsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save endpoints: {error}'**
  String endpointsSaveFailed(String error);

  /// No description provided for @settingsExtensions.
  ///
  /// In en, this message translates to:
  /// **'Extensions'**
  String get settingsExtensions;

  /// No description provided for @settingsExtensionsHint.
  ///
  /// In en, this message translates to:
  /// **'Discover and add plugins'**
  String get settingsExtensionsHint;

  /// No description provided for @settingsExtensionRepos.
  ///
  /// In en, this message translates to:
  /// **'Extension repositories'**
  String get settingsExtensionRepos;

  /// No description provided for @settingsExtensionReposHint.
  ///
  /// In en, this message translates to:
  /// **'Add your own extension sources'**
  String get settingsExtensionReposHint;

  /// No description provided for @sectionHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get sectionHistory;

  /// No description provided for @settingsDownloadHistory.
  ///
  /// In en, this message translates to:
  /// **'Download history'**
  String get settingsDownloadHistory;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsFont.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get settingsFont;

  /// No description provided for @fontSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get fontSystemDefault;

  /// No description provided for @settingsAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get settingsAccent;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic (device language)'**
  String get languageAuto;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @settingsAppName.
  ///
  /// In en, this message translates to:
  /// **'FLACidal Mobile'**
  String get settingsAppName;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Export config'**
  String get settingsExport;

  /// No description provided for @settingsImport.
  ///
  /// In en, this message translates to:
  /// **'Import config'**
  String get settingsImport;

  /// No description provided for @settingsChooseExportLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose export location'**
  String get settingsChooseExportLocation;

  /// No description provided for @settingsConfigExported.
  ///
  /// In en, this message translates to:
  /// **'Config exported to {path}'**
  String settingsConfigExported(String path);

  /// No description provided for @settingsExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String settingsExportFailed(String error);

  /// No description provided for @settingsImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import config'**
  String get settingsImportTitle;

  /// No description provided for @settingsImportWarning.
  ///
  /// In en, this message translates to:
  /// **'Importing will replace your current settings. Tidal, Soulseek, and Qobuz credentials will need to be re-entered after import.'**
  String get settingsImportWarning;

  /// No description provided for @settingsImportAnyway.
  ///
  /// In en, this message translates to:
  /// **'Import anyway'**
  String get settingsImportAnyway;

  /// No description provided for @settingsConfigImported.
  ///
  /// In en, this message translates to:
  /// **'Config imported'**
  String get settingsConfigImported;

  /// No description provided for @settingsImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String settingsImportFailed(String error);

  /// No description provided for @repoManagerHint.
  ///
  /// In en, this message translates to:
  /// **'https://...'**
  String get repoManagerHint;

  /// No description provided for @sourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get sourcesTitle;

  /// No description provided for @sourcesPriority.
  ///
  /// In en, this message translates to:
  /// **'Source priority'**
  String get sourcesPriority;

  /// No description provided for @sourcesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available sources'**
  String get sourcesAvailable;

  /// No description provided for @sourcesNone.
  ///
  /// In en, this message translates to:
  /// **'No sources found'**
  String get sourcesNone;

  /// No description provided for @sourcesPreferred.
  ///
  /// In en, this message translates to:
  /// **'Preferred source'**
  String get sourcesPreferred;

  /// No description provided for @sourcesPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary source'**
  String get sourcesPrimary;

  /// No description provided for @sourcesQualityFallback.
  ///
  /// In en, this message translates to:
  /// **'Quality fallback'**
  String get sourcesQualityFallback;

  /// No description provided for @sourcesQualityFallbackHint.
  ///
  /// In en, this message translates to:
  /// **'Retry at a lower quality when the requested one is unavailable'**
  String get sourcesQualityFallbackHint;

  /// No description provided for @sourcesQobuzCredentials.
  ///
  /// In en, this message translates to:
  /// **'Qobuz credentials'**
  String get sourcesQobuzCredentials;

  /// No description provided for @sourcesAppId.
  ///
  /// In en, this message translates to:
  /// **'App ID'**
  String get sourcesAppId;

  /// No description provided for @sourcesAppSecret.
  ///
  /// In en, this message translates to:
  /// **'App secret'**
  String get sourcesAppSecret;

  /// No description provided for @sourcesAuthToken.
  ///
  /// In en, this message translates to:
  /// **'Auth token'**
  String get sourcesAuthToken;

  /// No description provided for @sourcesTestConnection.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get sourcesTestConnection;

  /// No description provided for @sourcesConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected successfully'**
  String get sourcesConnected;

  /// No description provided for @sourcesConnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect: {error}'**
  String sourcesConnectFailed(String error);

  /// No description provided for @sourcesTestFailed.
  ///
  /// In en, this message translates to:
  /// **'The connection test failed: {error}'**
  String sourcesTestFailed(String error);

  /// No description provided for @sourcesQobuzUpdated.
  ///
  /// In en, this message translates to:
  /// **'Qobuz credentials updated'**
  String get sourcesQobuzUpdated;

  /// No description provided for @sourcesSoulseekCredentials.
  ///
  /// In en, this message translates to:
  /// **'Soulseek credentials'**
  String get sourcesSoulseekCredentials;

  /// No description provided for @sourcesSoulseekUpdated.
  ///
  /// In en, this message translates to:
  /// **'Soulseek credentials updated'**
  String get sourcesSoulseekUpdated;

  /// No description provided for @sourcesUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get sourcesUsername;

  /// No description provided for @sourcesPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get sourcesPassword;

  /// No description provided for @sourcesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load sources: {error}'**
  String sourcesLoadFailed(String error);

  /// No description provided for @sourcesSetPreferredFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not set the preferred source: {error}'**
  String sourcesSetPreferredFailed(String error);

  /// No description provided for @sourcesFallbackFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update the quality fallback: {error}'**
  String sourcesFallbackFailed(String error);

  /// No description provided for @sourcesSaveCredentialsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save credentials: {error}'**
  String sourcesSaveCredentialsFailed(String error);

  /// No description provided for @sourcesSaveOrderFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the source order: {error}'**
  String sourcesSaveOrderFailed(String error);

  /// No description provided for @extTitle.
  ///
  /// In en, this message translates to:
  /// **'Extensions'**
  String get extTitle;

  /// No description provided for @extTabInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get extTabInstalled;

  /// No description provided for @extTabBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get extTabBrowse;

  /// No description provided for @extNoneInstalled.
  ///
  /// In en, this message translates to:
  /// **'Nothing installed yet'**
  String get extNoneInstalled;

  /// No description provided for @extNoneInstalledHint.
  ///
  /// In en, this message translates to:
  /// **'Check the registry to find extensions'**
  String get extNoneInstalledHint;

  /// No description provided for @extNoneAvailable.
  ///
  /// In en, this message translates to:
  /// **'Nothing available right now'**
  String get extNoneAvailable;

  /// No description provided for @extRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get extRefresh;

  /// No description provided for @extSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Find extensions...'**
  String get extSearchHint;

  /// No description provided for @extCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get extCategoryAll;

  /// No description provided for @extCategoryDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get extCategoryDownload;

  /// No description provided for @extCategoryMetadata.
  ///
  /// In en, this message translates to:
  /// **'Metadata'**
  String get extCategoryMetadata;

  /// No description provided for @extCategoryLyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get extCategoryLyrics;

  /// No description provided for @extCategoryUtility.
  ///
  /// In en, this message translates to:
  /// **'Utility'**
  String get extCategoryUtility;

  /// No description provided for @extInstall.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get extInstall;

  /// No description provided for @extUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get extUpdate;

  /// No description provided for @extInstalledChip.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get extInstalledChip;

  /// No description provided for @extPermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions: {list}'**
  String extPermissions(String list);

  /// No description provided for @extSources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get extSources;

  /// No description provided for @extAddSource.
  ///
  /// In en, this message translates to:
  /// **'Add source'**
  String get extAddSource;

  /// No description provided for @extAddSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Add extension source'**
  String get extAddSourceTitle;

  /// No description provided for @extRepoUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'GitHub repository URL'**
  String get extRepoUrlLabel;

  /// No description provided for @extRepoUrlInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an address like https://github.com/owner/repo'**
  String get extRepoUrlInvalid;

  /// No description provided for @extAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get extAdd;

  /// No description provided for @extNoExtraSources.
  ///
  /// In en, this message translates to:
  /// **'No extra sources set up'**
  String get extNoExtraSources;

  /// No description provided for @extSourceAdded.
  ///
  /// In en, this message translates to:
  /// **'New source added'**
  String get extSourceAdded;

  /// No description provided for @extSourceAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add the source: {error}'**
  String extSourceAddFailed(String error);

  /// No description provided for @extSourceRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not remove the source: {error}'**
  String extSourceRemoveFailed(String error);

  /// No description provided for @extAdded.
  ///
  /// In en, this message translates to:
  /// **'Extension added'**
  String get extAdded;

  /// No description provided for @extInstallFailed.
  ///
  /// In en, this message translates to:
  /// **'Installation failed: {error}'**
  String extInstallFailed(String error);

  /// No description provided for @extUninstallTitle.
  ///
  /// In en, this message translates to:
  /// **'Uninstall extension'**
  String get extUninstallTitle;

  /// No description provided for @extUninstallConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove the \"{id}\" extension?'**
  String extUninstallConfirm(String id);

  /// No description provided for @extUninstall.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get extUninstall;

  /// No description provided for @extActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {error}'**
  String extActionFailed(String error);

  /// No description provided for @extConfigure.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get extConfigure;

  /// No description provided for @extConfigureTitle.
  ///
  /// In en, this message translates to:
  /// **'Configure {name}'**
  String extConfigureTitle(String name);

  /// No description provided for @extNothingToConfigure.
  ///
  /// In en, this message translates to:
  /// **'Nothing to configure here'**
  String get extNothingToConfigure;

  /// No description provided for @extConfigUpdated.
  ///
  /// In en, this message translates to:
  /// **'Configuration updated'**
  String get extConfigUpdated;

  /// No description provided for @extRegistryFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load the registry: {error}'**
  String extRegistryFailed(String error);

  /// No description provided for @extRegistrySourceFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the source {source}: {error}'**
  String extRegistrySourceFailed(String source, String error);

  /// No description provided for @extEnableTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable {name}?'**
  String extEnableTitle(String name);

  /// No description provided for @extEnableHosts.
  ///
  /// In en, this message translates to:
  /// **'This extension can contact:'**
  String get extEnableHosts;

  /// No description provided for @extEnableNoHosts.
  ///
  /// In en, this message translates to:
  /// **'No network hosts declared'**
  String get extEnableNoHosts;

  /// No description provided for @extEnablePermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get extEnablePermissions;

  /// No description provided for @extEnableNoPermissions.
  ///
  /// In en, this message translates to:
  /// **'None declared'**
  String get extEnableNoPermissions;

  /// No description provided for @librarySelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String librarySelected(int count);

  /// No description provided for @libraryCancelSelection.
  ///
  /// In en, this message translates to:
  /// **'Cancel selection'**
  String get libraryCancelSelection;

  /// No description provided for @libraryRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get libraryRename;

  /// No description provided for @libraryAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get libraryAnalyze;

  /// No description provided for @renameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename files'**
  String get renameTitle;

  /// No description provided for @renameTemplate.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get renameTemplate;

  /// No description provided for @renameCustomTemplate.
  ///
  /// In en, this message translates to:
  /// **'Custom template'**
  String get renameCustomTemplate;

  /// No description provided for @renamePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get renamePreview;

  /// No description provided for @renameApply.
  ///
  /// In en, this message translates to:
  /// **'Rename {count} file(s)'**
  String renameApply(int count);

  /// No description provided for @renamePreviewFirst.
  ///
  /// In en, this message translates to:
  /// **'Preview the new names before renaming'**
  String get renamePreviewFirst;

  /// No description provided for @renamePreviewFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not build the preview: {error}'**
  String renamePreviewFailed(String error);

  /// No description provided for @renameFailed.
  ///
  /// In en, this message translates to:
  /// **'Renaming failed: {error}'**
  String renameFailed(String error);

  /// No description provided for @renameDone.
  ///
  /// In en, this message translates to:
  /// **'{ok} renamed, {failed} failed'**
  String renameDone(int ok, int failed);

  /// No description provided for @renameRowError.
  ///
  /// In en, this message translates to:
  /// **'Cannot rename: {error}'**
  String renameRowError(String error);

  /// No description provided for @analyzerTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio analysis'**
  String get analyzerTitle;

  /// No description provided for @analyzerFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed: {error}'**
  String analyzerFailed(String error);

  /// No description provided for @analyzerVerdict.
  ///
  /// In en, this message translates to:
  /// **'Verdict'**
  String get analyzerVerdict;

  /// No description provided for @analyzerConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get analyzerConfidence;

  /// No description provided for @analyzerSampleRate.
  ///
  /// In en, this message translates to:
  /// **'Sample rate'**
  String get analyzerSampleRate;

  /// No description provided for @analyzerBitDepth.
  ///
  /// In en, this message translates to:
  /// **'Bit depth'**
  String get analyzerBitDepth;

  /// No description provided for @analyzerCutoff.
  ///
  /// In en, this message translates to:
  /// **'Spectrum cutoff'**
  String get analyzerCutoff;

  /// No description provided for @analyzerExpectedCutoff.
  ///
  /// In en, this message translates to:
  /// **'Expected cutoff'**
  String get analyzerExpectedCutoff;

  /// No description provided for @analyzerBpm.
  ///
  /// In en, this message translates to:
  /// **'Tempo'**
  String get analyzerBpm;

  /// No description provided for @analyzerKey.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get analyzerKey;

  /// No description provided for @analyzerDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get analyzerDetails;

  /// No description provided for @analyzerVerdictLossless.
  ///
  /// In en, this message translates to:
  /// **'Lossless'**
  String get analyzerVerdictLossless;

  /// No description provided for @analyzerVerdictLikelyUpscaled.
  ///
  /// In en, this message translates to:
  /// **'Likely upscaled'**
  String get analyzerVerdictLikelyUpscaled;

  /// No description provided for @analyzerVerdictUpscaled.
  ///
  /// In en, this message translates to:
  /// **'Upscaled'**
  String get analyzerVerdictUpscaled;

  /// No description provided for @analyzerHz.
  ///
  /// In en, this message translates to:
  /// **'{value} Hz'**
  String analyzerHz(int value);

  /// No description provided for @analyzerBits.
  ///
  /// In en, this message translates to:
  /// **'{value} bit'**
  String analyzerBits(int value);

  /// No description provided for @updateRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get updateRequiredTitle;

  /// No description provided for @updateRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'This version ({current}) is {behind} versions behind the latest release ({latest}). Update now to keep using the app.'**
  String updateRequiredBody(String current, int behind, String latest);

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get updateNow;

  /// No description provided for @updateDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get updateDownloading;

  /// No description provided for @updateDownloadingLong.
  ///
  /// In en, this message translates to:
  /// **'Downloading update...'**
  String get updateDownloadingLong;

  /// No description provided for @updateMigrationBody.
  ///
  /// In en, this message translates to:
  /// **'This update uses a new signing key, so it cannot be installed over your current version. Export your configuration (Settings > About > Export config), uninstall the beta, then install {latest}.'**
  String updateMigrationBody(String latest);

  /// No description provided for @updateOpenRelease.
  ///
  /// In en, this message translates to:
  /// **'Open the release page'**
  String get updateOpenRelease;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navQueue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get navQueue;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @downloadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get downloadingTitle;

  /// No description provided for @downloadedSoFar.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} downloaded so far'**
  String downloadedSoFar(int completed, int total);

  /// No description provided for @trackPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get trackPlay;

  /// No description provided for @trackPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get trackPause;

  /// No description provided for @trackDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get trackDownload;

  /// No description provided for @trackDownloadQuality.
  ///
  /// In en, this message translates to:
  /// **'Download quality'**
  String get trackDownloadQuality;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get historyClearTitle;

  /// No description provided for @historyClearBody.
  ///
  /// In en, this message translates to:
  /// **'This removes your entire download history; there is no going back.'**
  String get historyClearBody;

  /// No description provided for @historyClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get historyClear;

  /// No description provided for @historyWipe.
  ///
  /// In en, this message translates to:
  /// **'Wipe history'**
  String get historyWipe;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing downloaded yet'**
  String get historyEmpty;

  /// No description provided for @queueTitle.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queueTitle;

  /// No description provided for @queueRetryFailed.
  ///
  /// In en, this message translates to:
  /// **'Retry failed'**
  String get queueRetryFailed;

  /// No description provided for @queueActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get queueActive;

  /// No description provided for @queueQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get queueQueued;

  /// No description provided for @queueFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get queueFailed;

  /// No description provided for @queuePaused.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get queuePaused;

  /// No description provided for @queueEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing is downloading right now'**
  String get queueEmpty;

  /// No description provided for @queueTrackFallback.
  ///
  /// In en, this message translates to:
  /// **'Track {id}'**
  String queueTrackFallback(int id);

  /// No description provided for @queueSpeedLeft.
  ///
  /// In en, this message translates to:
  /// **'{speed}, {remaining} left'**
  String queueSpeedLeft(String speed, String remaining);

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {error}'**
  String errorGeneric(String error);

  /// No description provided for @tracksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 track} other{{count} tracks}}'**
  String tracksCount(int count);

  /// No description provided for @tracksQueued.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 track queued} other{{count} tracks queued}}'**
  String tracksQueued(int count);

  /// No description provided for @titleQueued.
  ///
  /// In en, this message translates to:
  /// **'{title} queued'**
  String titleQueued(String title);

  /// No description provided for @viewQueue.
  ///
  /// In en, this message translates to:
  /// **'View queue'**
  String get viewQueue;

  /// No description provided for @downloadCount.
  ///
  /// In en, this message translates to:
  /// **'Download {count}'**
  String downloadCount(int count);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get deselectAll;

  /// No description provided for @homeResolveFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to resolve that URL to a supported source'**
  String get homeResolveFailed;

  /// No description provided for @homeImportCsv.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get homeImportCsv;

  /// No description provided for @homeUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Drop a Tidal, Qobuz, Deezer, or Bandcamp URL here...'**
  String get homeUrlHint;

  /// No description provided for @homePasteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Fill in from clipboard'**
  String get homePasteTooltip;

  /// No description provided for @homeFetch.
  ///
  /// In en, this message translates to:
  /// **'Fetch'**
  String get homeFetch;

  /// No description provided for @homeGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started by pasting a Tidal, Qobuz, Deezer, or Bandcamp URL'**
  String get homeGetStarted;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// No description provided for @searchHintService.
  ///
  /// In en, this message translates to:
  /// **'Search {service}...'**
  String searchHintService(String service);

  /// No description provided for @searchSongsOnly.
  ///
  /// In en, this message translates to:
  /// **'Songs only'**
  String get searchSongsOnly;

  /// No description provided for @searchSortRelevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get searchSortRelevance;

  /// No description provided for @searchSortDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get searchSortDate;

  /// No description provided for @searchTabTracks.
  ///
  /// In en, this message translates to:
  /// **'Tracks ({count})'**
  String searchTabTracks(int count);

  /// No description provided for @searchTabAlbums.
  ///
  /// In en, this message translates to:
  /// **'Albums ({count})'**
  String searchTabAlbums(int count);

  /// No description provided for @searchTabArtists.
  ///
  /// In en, this message translates to:
  /// **'Artists ({count})'**
  String searchTabArtists(int count);

  /// No description provided for @searchTabDeezer.
  ///
  /// In en, this message translates to:
  /// **'Deezer ({count})'**
  String searchTabDeezer(int count);

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Look up tracks, albums, or artists'**
  String get searchPrompt;

  /// No description provided for @searchDeezerPrompt.
  ///
  /// In en, this message translates to:
  /// **'Search Deezer to find results from anywhere'**
  String get searchDeezerPrompt;

  /// No description provided for @openInTidal.
  ///
  /// In en, this message translates to:
  /// **'Open in Tidal'**
  String get openInTidal;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @deleteFilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete files'**
  String get deleteFilesTitle;

  /// No description provided for @deleteFilesBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Remove the selected file?} other{Remove {count} selected files?}}'**
  String deleteFilesBody(int count);

  /// No description provided for @discLabel.
  ///
  /// In en, this message translates to:
  /// **'Disc {number}'**
  String discLabel(int number);

  /// No description provided for @lyricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get lyricsTitle;

  /// No description provided for @lyricsMissingInput.
  ///
  /// In en, this message translates to:
  /// **'Missing both a file path and track info.'**
  String get lyricsMissingInput;

  /// No description provided for @lyricsNoFilePath.
  ///
  /// In en, this message translates to:
  /// **'Lyrics can\'t be embedded without a file path.'**
  String get lyricsNoFilePath;

  /// No description provided for @lyricsNothingToEmbed.
  ///
  /// In en, this message translates to:
  /// **'There\'s nothing to embed.'**
  String get lyricsNothingToEmbed;

  /// No description provided for @lyricsEmbedded.
  ///
  /// In en, this message translates to:
  /// **'Lyrics embedded.'**
  String get lyricsEmbedded;

  /// No description provided for @lyricsEmbedFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to embed lyrics: {error}'**
  String lyricsEmbedFailed(String error);

  /// No description provided for @lyricsInstrumental.
  ///
  /// In en, this message translates to:
  /// **'Instrumental'**
  String get lyricsInstrumental;

  /// No description provided for @lyricsEmbedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Embed lyrics into the FLAC'**
  String get lyricsEmbedTooltip;

  /// No description provided for @lyricsTabSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get lyricsTabSynced;

  /// No description provided for @lyricsTabPlain.
  ///
  /// In en, this message translates to:
  /// **'Plain'**
  String get lyricsTabPlain;

  /// No description provided for @lyricsLooksInstrumental.
  ///
  /// In en, this message translates to:
  /// **'This one looks to be instrumental.'**
  String get lyricsLooksInstrumental;

  /// No description provided for @lyricsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t find lyrics for this track.'**
  String get lyricsNotFound;

  /// No description provided for @lyricsNoSynced.
  ///
  /// In en, this message translates to:
  /// **'No synced lyrics on hand.'**
  String get lyricsNoSynced;

  /// No description provided for @lyricsNoPlain.
  ///
  /// In en, this message translates to:
  /// **'No plain lyrics on hand.'**
  String get lyricsNoPlain;

  /// No description provided for @metaTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit metadata'**
  String get metaTitle;

  /// No description provided for @metaUpdated.
  ///
  /// In en, this message translates to:
  /// **'Metadata updated'**
  String get metaUpdated;

  /// No description provided for @metaSavedCover.
  ///
  /// In en, this message translates to:
  /// **'Saved cover art to {path}'**
  String metaSavedCover(String path);

  /// No description provided for @metaSavedLyrics.
  ///
  /// In en, this message translates to:
  /// **'Saved lyrics to {path}'**
  String metaSavedLyrics(String path);

  /// No description provided for @metaNothingNew.
  ///
  /// In en, this message translates to:
  /// **'Nothing new to update'**
  String get metaNothingNew;

  /// No description provided for @metaFieldsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Fields updated: {fields}'**
  String metaFieldsUpdated(String fields);

  /// No description provided for @metaExtractCover.
  ///
  /// In en, this message translates to:
  /// **'Extract cover art'**
  String get metaExtractCover;

  /// No description provided for @metaSaveLyrics.
  ///
  /// In en, this message translates to:
  /// **'Save lyrics'**
  String get metaSaveLyrics;

  /// No description provided for @metaReEnrich.
  ///
  /// In en, this message translates to:
  /// **'Re-enrich'**
  String get metaReEnrich;

  /// No description provided for @metaFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get metaFieldTitle;

  /// No description provided for @metaFieldArtist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get metaFieldArtist;

  /// No description provided for @metaFieldAlbum.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get metaFieldAlbum;

  /// No description provided for @metaFieldAlbumArtist.
  ///
  /// In en, this message translates to:
  /// **'Album artist'**
  String get metaFieldAlbumArtist;

  /// No description provided for @metaFieldTrackNumber.
  ///
  /// In en, this message translates to:
  /// **'Track #'**
  String get metaFieldTrackNumber;

  /// No description provided for @metaFieldDiscNumber.
  ///
  /// In en, this message translates to:
  /// **'Disc #'**
  String get metaFieldDiscNumber;

  /// No description provided for @metaFieldYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get metaFieldYear;

  /// No description provided for @metaFieldGenre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get metaFieldGenre;

  /// No description provided for @metaFieldIsrc.
  ///
  /// In en, this message translates to:
  /// **'ISRC'**
  String get metaFieldIsrc;

  /// No description provided for @metaFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get metaFieldLabel;

  /// No description provided for @metaFieldCopyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright'**
  String get metaFieldCopyright;

  /// No description provided for @metaFieldComposer.
  ///
  /// In en, this message translates to:
  /// **'Composer'**
  String get metaFieldComposer;

  /// No description provided for @metaFieldComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get metaFieldComment;

  /// No description provided for @csvTitle.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get csvTitle;

  /// No description provided for @csvPick.
  ///
  /// In en, this message translates to:
  /// **'Pick a CSV file'**
  String get csvPick;

  /// No description provided for @csvColumns.
  ///
  /// In en, this message translates to:
  /// **'CSV files need these columns: Track Name, Artist Name(s), Album Name, ISRC. Spotify\'s export format works too.'**
  String get csvColumns;

  /// No description provided for @csvChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get csvChoose;

  /// No description provided for @csvQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get csvQuality;

  /// No description provided for @csvMatch.
  ///
  /// In en, this message translates to:
  /// **'Match tracks'**
  String get csvMatch;

  /// No description provided for @csvNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No tracks matched, nothing to queue'**
  String get csvNoMatch;

  /// No description provided for @csvMatched.
  ///
  /// In en, this message translates to:
  /// **'{matched} / {total} matched'**
  String csvMatched(int matched, int total);

  /// No description provided for @csvQueue.
  ///
  /// In en, this message translates to:
  /// **'Queue {count}'**
  String csvQueue(int count);

  /// No description provided for @convertTitle.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get convertTitle;

  /// No description provided for @convertFfmpegUnavailable.
  ///
  /// In en, this message translates to:
  /// **'FFmpeg is unavailable'**
  String get convertFfmpegUnavailable;

  /// No description provided for @convertFfmpegBody.
  ///
  /// In en, this message translates to:
  /// **'FFmpeg needs to be installed on this device for format conversion to work.'**
  String get convertFfmpegBody;

  /// No description provided for @convertFilesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} file(s) selected'**
  String convertFilesSelected(int count);

  /// No description provided for @convertMore.
  ///
  /// In en, this message translates to:
  /// **'... and {count} more'**
  String convertMore(int count);

  /// No description provided for @convertOutputFormat.
  ///
  /// In en, this message translates to:
  /// **'Output format'**
  String get convertOutputFormat;

  /// No description provided for @convertBitrate.
  ///
  /// In en, this message translates to:
  /// **'Bitrate: {kbps} kbps'**
  String convertBitrate(int kbps);

  /// No description provided for @convertKbps.
  ///
  /// In en, this message translates to:
  /// **'{kbps} kbps'**
  String convertKbps(int kbps);

  /// No description provided for @convertDeleteOriginals.
  ///
  /// In en, this message translates to:
  /// **'Delete original files'**
  String get convertDeleteOriginals;

  /// No description provided for @convertDeleteOriginalsHint.
  ///
  /// In en, this message translates to:
  /// **'Deletes the original FLAC once conversion finishes'**
  String get convertDeleteOriginalsHint;

  /// No description provided for @convertConverting.
  ///
  /// In en, this message translates to:
  /// **'Converting...'**
  String get convertConverting;

  /// No description provided for @convertDone.
  ///
  /// In en, this message translates to:
  /// **'Conversion finished'**
  String get convertDone;

  /// No description provided for @convertFailed.
  ///
  /// In en, this message translates to:
  /// **'Conversion failed: {error}'**
  String convertFailed(String error);

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @libraryTitleCount.
  ///
  /// In en, this message translates to:
  /// **'Library ({count})'**
  String libraryTitleCount(int count);

  /// No description provided for @libraryTrackView.
  ///
  /// In en, this message translates to:
  /// **'Track view'**
  String get libraryTrackView;

  /// No description provided for @libraryAlbumView.
  ///
  /// In en, this message translates to:
  /// **'Album view'**
  String get libraryAlbumView;

  /// No description provided for @librarySort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get librarySort;

  /// No description provided for @librarySortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get librarySortName;

  /// No description provided for @librarySortDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get librarySortDate;

  /// No description provided for @librarySortSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get librarySortSize;

  /// No description provided for @libraryFilterSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get libraryFilterSource;

  /// No description provided for @libraryFilterQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get libraryFilterQuality;

  /// No description provided for @libraryFilterFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get libraryFilterFormat;

  /// No description provided for @libraryFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get libraryFilterAll;

  /// No description provided for @libraryFilterUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get libraryFilterUnknown;

  /// No description provided for @libraryFilterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get libraryFilterClear;

  /// No description provided for @libraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t downloaded anything yet'**
  String get libraryEmpty;

  /// No description provided for @libraryEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Head to the Home page to download some tracks'**
  String get libraryEmptyHint;

  /// No description provided for @librarySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search your library...'**
  String get librarySearchHint;

  /// No description provided for @libraryNothingMatches.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches'**
  String get libraryNothingMatches;

  /// No description provided for @libraryUnknownAlbum.
  ///
  /// In en, this message translates to:
  /// **'Unknown album'**
  String get libraryUnknownAlbum;

  /// No description provided for @libraryMetadata.
  ///
  /// In en, this message translates to:
  /// **'Metadata'**
  String get libraryMetadata;

  /// No description provided for @librarySaveCover.
  ///
  /// In en, this message translates to:
  /// **'Save cover art'**
  String get librarySaveCover;

  /// No description provided for @libraryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete file'**
  String get libraryDeleteTitle;

  /// No description provided for @libraryDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\"?'**
  String libraryDeleteBody(String name);

  /// No description provided for @notifGrabbing.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Grabbing 1 track...} other{Grabbing {count} tracks...}}'**
  String notifGrabbing(int count);

  /// No description provided for @notifProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} tracks downloaded'**
  String notifProgress(int completed, int total);

  /// No description provided for @notifUpdateDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading update...'**
  String get notifUpdateDownloading;

  /// No description provided for @notifUpdateProgress.
  ///
  /// In en, this message translates to:
  /// **'Downloading update: {percent}%'**
  String notifUpdateProgress(int percent);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
