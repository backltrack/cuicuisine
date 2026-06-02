// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Cuicuisine`
  String get title {
    return Intl.message(
      'Cuicuisine',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Hors-ligne`
  String get offline_alert_title {
    return Intl.message(
      'Hors-ligne',
      name: 'offline_alert_title',
      desc: '',
      args: [],
    );
  }

  /// `Veux-tu passer en mode hors-ligne ? Les modifications seront synchronisée dès que le réseau est de retour.`
  String get offline_alert_description {
    return Intl.message(
      'Veux-tu passer en mode hors-ligne ? Les modifications seront synchronisée dès que le réseau est de retour.',
      name: 'offline_alert_description',
      desc: '',
      args: [],
    );
  }

  /// `Attends le retour du réseau ou tente de te connecter à un autre serveur.`
  String get offline_refused_toast {
    return Intl.message(
      'Attends le retour du réseau ou tente de te connecter à un autre serveur.',
      name: 'offline_refused_toast',
      desc: '',
      args: [],
    );
  }

  /// `Attends d'être en ligne pour pouvoir te connecter.`
  String get connexion_needed {
    return Intl.message(
      'Attends d\'être en ligne pour pouvoir te connecter.',
      name: 'connexion_needed',
      desc: '',
      args: [],
    );
  }

  /// `Cette action nécessite une connexion.`
  String get connexion_needed2 {
    return Intl.message(
      'Cette action nécessite une connexion.',
      name: 'connexion_needed2',
      desc: '',
      args: [],
    );
  }

  /// `Choisis un livre !`
  String get book_choice {
    return Intl.message(
      'Choisis un livre !',
      name: 'book_choice',
      desc: '',
      args: [],
    );
  }

  /// `Aucune recette disponible`
  String get no_recipe {
    return Intl.message(
      'Aucune recette disponible',
      name: 'no_recipe',
      desc: '',
      args: [],
    );
  }

  /// `Ajoute un livre !`
  String get add_book {
    return Intl.message(
      'Ajoute un livre !',
      name: 'add_book',
      desc: '',
      args: [],
    );
  }

  /// `Erreur de chargement`
  String get loading_error {
    return Intl.message(
      'Erreur de chargement',
      name: 'loading_error',
      desc: '',
      args: [],
    );
  }

  /// `Favoris`
  String get filter_fav {
    return Intl.message(
      'Favoris',
      name: 'filter_fav',
      desc: '',
      args: [],
    );
  }

  /// `Temps`
  String get filter_time {
    return Intl.message(
      'Temps',
      name: 'filter_time',
      desc: '',
      args: [],
    );
  }

  /// `Ingrédients`
  String get filter_ingredients {
    return Intl.message(
      'Ingrédients',
      name: 'filter_ingredients',
      desc: '',
      args: [],
    );
  }

  /// `Tags`
  String get filter_tags {
    return Intl.message(
      'Tags',
      name: 'filter_tags',
      desc: '',
      args: [],
    );
  }

  /// `Appliquer`
  String get filter_apply {
    return Intl.message(
      'Appliquer',
      name: 'filter_apply',
      desc: '',
      args: [],
    );
  }

  /// `Alphabet`
  String get bottom_bar_sort_alpha {
    return Intl.message(
      'Alphabet',
      name: 'bottom_bar_sort_alpha',
      desc: '',
      args: [],
    );
  }

  /// `Temps`
  String get bottom_bar_sort_time {
    return Intl.message(
      'Temps',
      name: 'bottom_bar_sort_time',
      desc: '',
      args: [],
    );
  }

  /// `Ajouter`
  String get add_button {
    return Intl.message(
      'Ajouter',
      name: 'add_button',
      desc: '',
      args: [],
    );
  }

  /// `Nouveau`
  String get new_button {
    return Intl.message(
      'Nouveau',
      name: 'new_button',
      desc: '',
      args: [],
    );
  }

  /// `Rejoindre`
  String get join_button {
    return Intl.message(
      'Rejoindre',
      name: 'join_button',
      desc: '',
      args: [],
    );
  }

  /// `Recherche`
  String get search {
    return Intl.message(
      'Recherche',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Liste des courses`
  String get shopping_list {
    return Intl.message(
      'Liste des courses',
      name: 'shopping_list',
      desc: '',
      args: [],
    );
  }

  /// `Paramètres`
  String get settings {
    return Intl.message(
      'Paramètres',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Compte`
  String get account {
    return Intl.message(
      'Compte',
      name: 'account',
      desc: '',
      args: [],
    );
  }

  /// `Temps`
  String get time_widget_text {
    return Intl.message(
      'Temps',
      name: 'time_widget_text',
      desc: '',
      args: [],
    );
  }

  /// `Préparation`
  String get time_widget_preparation {
    return Intl.message(
      'Préparation',
      name: 'time_widget_preparation',
      desc: '',
      args: [],
    );
  }

  /// `Attente`
  String get time_widget_waiting {
    return Intl.message(
      'Attente',
      name: 'time_widget_waiting',
      desc: '',
      args: [],
    );
  }

  /// `Cuisson`
  String get time_widget_cooking {
    return Intl.message(
      'Cuisson',
      name: 'time_widget_cooking',
      desc: '',
      args: [],
    );
  }

  /// `min`
  String get time_minutes_abr {
    return Intl.message(
      'min',
      name: 'time_minutes_abr',
      desc: '',
      args: [],
    );
  }

  /// `Ingrédients`
  String get ingredient_widget_title {
    return Intl.message(
      'Ingrédients',
      name: 'ingredient_widget_title',
      desc: '',
      args: [],
    );
  }

  /// `Personnes`
  String get ingredient_widget_quantity_type {
    return Intl.message(
      'Personnes',
      name: 'ingredient_widget_quantity_type',
      desc: '',
      args: [],
    );
  }

  /// `Type de quantité`
  String get ingredient_quantity_type_dialog_name {
    return Intl.message(
      'Type de quantité',
      name: 'ingredient_quantity_type_dialog_name',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get ingredient_quantity_type_dialog_label {
    return Intl.message(
      'Type',
      name: 'ingredient_quantity_type_dialog_label',
      desc: '',
      args: [],
    );
  }

  /// `Coefficient multiplicateur`
  String get ingredient_proportion_coeff {
    return Intl.message(
      'Coefficient multiplicateur',
      name: 'ingredient_proportion_coeff',
      desc: '',
      args: [],
    );
  }

  /// `Copier le lien`
  String get recipe_menu_share {
    return Intl.message(
      'Copier le lien',
      name: 'recipe_menu_share',
      desc: '',
      args: [],
    );
  }

  /// `Ajouter au panier`
  String get recipe_menu_cart {
    return Intl.message(
      'Ajouter au panier',
      name: 'recipe_menu_cart',
      desc: '',
      args: [],
    );
  }

  /// `Copier dans`
  String get recipe_menu_copy_to_book {
    return Intl.message(
      'Copier dans',
      name: 'recipe_menu_copy_to_book',
      desc: '',
      args: [],
    );
  }

  /// `Exporter en pdf`
  String get recipe_menu_export_to_pdf {
    return Intl.message(
      'Exporter en pdf',
      name: 'recipe_menu_export_to_pdf',
      desc: '',
      args: [],
    );
  }

  /// `Supprimer`
  String get recipe_menu_remove {
    return Intl.message(
      'Supprimer',
      name: 'recipe_menu_remove',
      desc: '',
      args: [],
    );
  }

  /// `Nouvelle recette`
  String get new_recipe_name {
    return Intl.message(
      'Nouvelle recette',
      name: 'new_recipe_name',
      desc: '',
      args: [],
    );
  }

  /// `Nouvelle étape`
  String get new_recipe_step {
    return Intl.message(
      'Nouvelle étape',
      name: 'new_recipe_step',
      desc: '',
      args: [],
    );
  }

  /// `Étapes`
  String get steps_widget_title {
    return Intl.message(
      'Étapes',
      name: 'steps_widget_title',
      desc: '',
      args: [],
    );
  }

  /// `Étape`
  String get steps_widget_step {
    return Intl.message(
      'Étape',
      name: 'steps_widget_step',
      desc: '',
      args: [],
    );
  }

  /// `cac`
  String get unit_tsp {
    return Intl.message(
      'cac',
      name: 'unit_tsp',
      desc: '',
      args: [],
    );
  }

  /// `cas`
  String get unit_tbs {
    return Intl.message(
      'cas',
      name: 'unit_tbs',
      desc: '',
      args: [],
    );
  }

  /// `tasse`
  String get unit_cup {
    return Intl.message(
      'tasse',
      name: 'unit_cup',
      desc: '',
      args: [],
    );
  }

  /// `bouchon`
  String get unit_cap {
    return Intl.message(
      'bouchon',
      name: 'unit_cap',
      desc: '',
      args: [],
    );
  }

  /// `pincée`
  String get unit_pinch {
    return Intl.message(
      'pincée',
      name: 'unit_pinch',
      desc: '',
      args: [],
    );
  }

  /// `goutte`
  String get unit_drop {
    return Intl.message(
      'goutte',
      name: 'unit_drop',
      desc: '',
      args: [],
    );
  }

  /// `Changer de thème`
  String get general_settings_theme {
    return Intl.message(
      'Changer de thème',
      name: 'general_settings_theme',
      desc: '',
      args: [],
    );
  }

  /// `Changer la langue`
  String get general_settings_language {
    return Intl.message(
      'Changer la langue',
      name: 'general_settings_language',
      desc: '',
      args: [],
    );
  }

  /// `Garder l'écran allumé`
  String get general_settings_awake {
    return Intl.message(
      'Garder l\'écran allumé',
      name: 'general_settings_awake',
      desc: '',
      args: [],
    );
  }

  /// `Déconnexion`
  String get general_settings_signout {
    return Intl.message(
      'Déconnexion',
      name: 'general_settings_signout',
      desc: '',
      args: [],
    );
  }

  /// `Exporter mes livres`
  String get general_settings_export {
    return Intl.message(
      'Exporter mes livres',
      name: 'general_settings_export',
      desc: '',
      args: [],
    );
  }

  /// `Importer des livres`
  String get general_settings_import {
    return Intl.message(
      'Importer des livres',
      name: 'general_settings_import',
      desc: '',
      args: [],
    );
  }

  /// `Adresse serveur`
  String get general_settings_server {
    return Intl.message(
      'Adresse serveur',
      name: 'general_settings_server',
      desc: '',
      args: [],
    );
  }

  /// `État de la synchronisation`
  String get general_settings_synchronization {
    return Intl.message(
      'État de la synchronisation',
      name: 'general_settings_synchronization',
      desc: '',
      args: [],
    );
  }

  /// `État de la synchronisation`
  String get synchronization_status_title {
    return Intl.message(
      'État de la synchronisation',
      name: 'synchronization_status_title',
      desc: '',
      args: [],
    );
  }

  /// `À jour`
  String get synchronization_status_up_to_date {
    return Intl.message(
      'À jour',
      name: 'synchronization_status_up_to_date',
      desc: '',
      args: [],
    );
  }

  /// `Synchronisation nécessaire`
  String get synchronization_status_need_sync {
    return Intl.message(
      'Synchronisation nécessaire',
      name: 'synchronization_status_need_sync',
      desc: '',
      args: [],
    );
  }

  /// `Synchronisation en cours...`
  String get synchronizing {
    return Intl.message(
      'Synchronisation en cours...',
      name: 'synchronizing',
      desc: '',
      args: [],
    );
  }

  /// `État: `
  String get synchronization_status {
    return Intl.message(
      'État: ',
      name: 'synchronization_status',
      desc: '',
      args: [],
    );
  }

  /// `Ta version de l'application est obsolète. Mets-la à jour pour continuer à utiliser toutes les fonctionnalités.`
  String get outdated_version_banner {
    return Intl.message(
      'Ta version de l\'application est obsolète. Mets-la à jour pour continuer à utiliser toutes les fonctionnalités.',
      name: 'outdated_version_banner',
      desc: '',
      args: [],
    );
  }

  /// `Télécharger la mise à jour`
  String get outdated_version_download {
    return Intl.message(
      'Télécharger la mise à jour',
      name: 'outdated_version_download',
      desc: '',
      args: [],
    );
  }

  /// `Mets l'application à jour pour te connecter.`
  String get outdated_version_login_blocked {
    return Intl.message(
      'Mets l\'application à jour pour te connecter.',
      name: 'outdated_version_login_blocked',
      desc: '',
      args: [],
    );
  }

  /// `État inconnu`
  String get synchronization_status_failure {
    return Intl.message(
      'État inconnu',
      name: 'synchronization_status_failure',
      desc: '',
      args: [],
    );
  }

  /// `File d'attente: `
  String get synchronization_queue {
    return Intl.message(
      'File d\'attente: ',
      name: 'synchronization_queue',
      desc: '',
      args: [],
    );
  }

  /// `Supprimer mon compte`
  String get remove_account {
    return Intl.message(
      'Supprimer mon compte',
      name: 'remove_account',
      desc: '',
      args: [],
    );
  }

  /// `Supprimer`
  String get remove_button {
    return Intl.message(
      'Supprimer',
      name: 'remove_button',
      desc: '',
      args: [],
    );
  }

  /// `Confirme ton email afin de supprimer ton compte définitivement.`
  String get remove_account_method {
    return Intl.message(
      'Confirme ton email afin de supprimer ton compte définitivement.',
      name: 'remove_account_method',
      desc: '',
      args: [],
    );
  }

  /// `En cliquant sur le bouton ci-dessous vous acceptez la suppression définitive de toutes vos données, aussi bien locales que cloud. Les personnes avec qui vous partagez vos livres n'y auront plus accès.`
  String get remove_account_agreement {
    return Intl.message(
      'En cliquant sur le bouton ci-dessous vous acceptez la suppression définitive de toutes vos données, aussi bien locales que cloud. Les personnes avec qui vous partagez vos livres n\'y auront plus accès.',
      name: 'remove_account_agreement',
      desc: '',
      args: [],
    );
  }

  /// `Déconnexion`
  String get sign_out_popup_title {
    return Intl.message(
      'Déconnexion',
      name: 'sign_out_popup_title',
      desc: '',
      args: [],
    );
  }

  /// `Veux-tu vraiment te déconnecter ?`
  String get sign_out_popup_description {
    return Intl.message(
      'Veux-tu vraiment te déconnecter ?',
      name: 'sign_out_popup_description',
      desc: '',
      args: [],
    );
  }

  /// `e-mail`
  String get auth_email_label {
    return Intl.message(
      'e-mail',
      name: 'auth_email_label',
      desc: '',
      args: [],
    );
  }

  /// `Mot de passe`
  String get auth_password_label {
    return Intl.message(
      'Mot de passe',
      name: 'auth_password_label',
      desc: '',
      args: [],
    );
  }

  /// `Code`
  String get auth_code_label {
    return Intl.message(
      'Code',
      name: 'auth_code_label',
      desc: '',
      args: [],
    );
  }

  /// `Longueur > `
  String get auth_password_req_len {
    return Intl.message(
      'Longueur > ',
      name: 'auth_password_req_len',
      desc: '',
      args: [],
    );
  }

  /// `Caractères min/maj `
  String get auth_password_req_uplow {
    return Intl.message(
      'Caractères min/maj ',
      name: 'auth_password_req_uplow',
      desc: '',
      args: [],
    );
  }

  /// `Chiffres`
  String get auth_password_req_digit {
    return Intl.message(
      'Chiffres',
      name: 'auth_password_req_digit',
      desc: '',
      args: [],
    );
  }

  /// `Caractères spéciaux`
  String get auth_password_req_sepcial {
    return Intl.message(
      'Caractères spéciaux',
      name: 'auth_password_req_sepcial',
      desc: '',
      args: [],
    );
  }

  /// `Connexion`
  String get auth_connexion {
    return Intl.message(
      'Connexion',
      name: 'auth_connexion',
      desc: '',
      args: [],
    );
  }

  /// `Suivant`
  String get auth_next {
    return Intl.message(
      'Suivant',
      name: 'auth_next',
      desc: '',
      args: [],
    );
  }

  /// `Pas encore de compte ?`
  String get auth_register {
    return Intl.message(
      'Pas encore de compte ?',
      name: 'auth_register',
      desc: '',
      args: [],
    );
  }

  /// `Prénom`
  String get auth_register_name {
    return Intl.message(
      'Prénom',
      name: 'auth_register_name',
      desc: '',
      args: [],
    );
  }

  /// `Nom`
  String get auth_register_lastname {
    return Intl.message(
      'Nom',
      name: 'auth_register_lastname',
      desc: '',
      args: [],
    );
  }

  /// `Mot de passe oublié`
  String get auth_forgotten_password {
    return Intl.message(
      'Mot de passe oublié',
      name: 'auth_forgotten_password',
      desc: '',
      args: [],
    );
  }

  /// `Entre ton email pour obtenir le code de renouvellement du mot de passe`
  String get auth_forgotten_password_method {
    return Intl.message(
      'Entre ton email pour obtenir le code de renouvellement du mot de passe',
      name: 'auth_forgotten_password_method',
      desc: '',
      args: [],
    );
  }

  /// `Obtenir le code par email`
  String get auth_renewal_link {
    return Intl.message(
      'Obtenir le code par email',
      name: 'auth_renewal_link',
      desc: '',
      args: [],
    );
  }

  /// `Email envoyé`
  String get auth_renewal_email_sent {
    return Intl.message(
      'Email envoyé',
      name: 'auth_renewal_email_sent',
      desc: '',
      args: [],
    );
  }

  /// `Changement mdp`
  String get change_password {
    return Intl.message(
      'Changement mdp',
      name: 'change_password',
      desc: '',
      args: [],
    );
  }

  /// `Nouveau mot de passe`
  String get change_password_label_new {
    return Intl.message(
      'Nouveau mot de passe',
      name: 'change_password_label_new',
      desc: '',
      args: [],
    );
  }

  /// `Un problème est survenu, essaie à nouveau.`
  String get change_password_issue {
    return Intl.message(
      'Un problème est survenu, essaie à nouveau.',
      name: 'change_password_issue',
      desc: '',
      args: [],
    );
  }

  /// `Annuler`
  String get cancel {
    return Intl.message(
      'Annuler',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Désactiver`
  String get disable {
    return Intl.message(
      'Désactiver',
      name: 'disable',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `J'ai compris`
  String get understood {
    return Intl.message(
      'J\'ai compris',
      name: 'understood',
      desc: '',
      args: [],
    );
  }

  /// `Me le rappeler`
  String get remind_me {
    return Intl.message(
      'Me le rappeler',
      name: 'remind_me',
      desc: '',
      args: [],
    );
  }

  /// `Supprimer`
  String get popup_delete_title {
    return Intl.message(
      'Supprimer',
      name: 'popup_delete_title',
      desc: '',
      args: [],
    );
  }

  /// `Veux-tu vraiment supprimer `
  String get popup_delete_description_as_owner {
    return Intl.message(
      'Veux-tu vraiment supprimer ',
      name: 'popup_delete_description_as_owner',
      desc: '',
      args: [],
    );
  }

  /// `Tu n'es pas propriétaire du livre.`
  String get popup_delete_ownership_warning {
    return Intl.message(
      'Tu n\'es pas propriétaire du livre.',
      name: 'popup_delete_ownership_warning',
      desc: '',
      args: [],
    );
  }

  /// `Es-tu sûr de vouloir supprimer `
  String get popup_delete_description_as_collaborator {
    return Intl.message(
      'Es-tu sûr de vouloir supprimer ',
      name: 'popup_delete_description_as_collaborator',
      desc: '',
      args: [],
    );
  }

  /// ` pour tous les utilisateurs ?`
  String get popup_delete_description_user_warning {
    return Intl.message(
      ' pour tous les utilisateurs ?',
      name: 'popup_delete_description_user_warning',
      desc: '',
      args: [],
    );
  }

  /// ` ainsi que toutes ses recettes pour tous les utilisateurs ?`
  String get popup_delete_for_all {
    return Intl.message(
      ' ainsi que toutes ses recettes pour tous les utilisateurs ?',
      name: 'popup_delete_for_all',
      desc: '',
      args: [],
    );
  }

  /// `Quitter`
  String get popup_quit_title {
    return Intl.message(
      'Quitter',
      name: 'popup_quit_title',
      desc: '',
      args: [],
    );
  }

  /// `Veux-tu vraiment quitter `
  String get popup_quit_description {
    return Intl.message(
      'Veux-tu vraiment quitter ',
      name: 'popup_quit_description',
      desc: '',
      args: [],
    );
  }

  /// `Retirer`
  String get popup_remove_user_title {
    return Intl.message(
      'Retirer',
      name: 'popup_remove_user_title',
      desc: '',
      args: [],
    );
  }

  /// `Veux-tu vraiment retirer l'accès à `
  String get popup_remove_user_description {
    return Intl.message(
      'Veux-tu vraiment retirer l\'accès à ',
      name: 'popup_remove_user_description',
      desc: '',
      args: [],
    );
  }

  /// `Veux-tu vraiment supprimer cette image ?`
  String get popup_remove_image_description {
    return Intl.message(
      'Veux-tu vraiment supprimer cette image ?',
      name: 'popup_remove_image_description',
      desc: '',
      args: [],
    );
  }

  /// `Quitter sans sauvegarder`
  String get popup_loose_data_title {
    return Intl.message(
      'Quitter sans sauvegarder',
      name: 'popup_loose_data_title',
      desc: '',
      args: [],
    );
  }

  /// `Tu pourrais perdre des données. Merci d'utiliser le bouton`
  String get popup_loose_data_1 {
    return Intl.message(
      'Tu pourrais perdre des données. Merci d\'utiliser le bouton',
      name: 'popup_loose_data_1',
      desc: '',
      args: [],
    );
  }

  /// `pour sauvegarder ton travail.\n`
  String get popup_loose_data_2 {
    return Intl.message(
      'pour sauvegarder ton travail.\n',
      name: 'popup_loose_data_2',
      desc: '',
      args: [],
    );
  }

  /// `Veux tu vraiment quitter sans sauvegarder ?`
  String get popup_loose_data_3 {
    return Intl.message(
      'Veux tu vraiment quitter sans sauvegarder ?',
      name: 'popup_loose_data_3',
      desc: '',
      args: [],
    );
  }

  /// `Partager un livre`
  String get info_share_book_title {
    return Intl.message(
      'Partager un livre',
      name: 'info_share_book_title',
      desc: '',
      args: [],
    );
  }

  /// `Tu t'apprêtes à partager ce livre.`
  String get info_share_book_description1 {
    return Intl.message(
      'Tu t\'apprêtes à partager ce livre.',
      name: 'info_share_book_description1',
      desc: '',
      args: [],
    );
  }

  /// `Par défaut, les collaborateurs pourront seulement voir les recettes.`
  String get info_share_book_description2 {
    return Intl.message(
      'Par défaut, les collaborateurs pourront seulement voir les recettes.',
      name: 'info_share_book_description2',
      desc: '',
      args: [],
    );
  }

  /// `Tu peux leur accorder plus de droits ou leurs retirer l'accès à tout moment depuis les paramètres utilisateurs ci-dessous.`
  String get info_share_book_description_owner {
    return Intl.message(
      'Tu peux leur accorder plus de droits ou leurs retirer l\'accès à tout moment depuis les paramètres utilisateurs ci-dessous.',
      name: 'info_share_book_description_owner',
      desc: '',
      args: [],
    );
  }

  /// `Le propriétaire du livre peut leur accorder plus de droits ou leurs retirer l'accès à tout moment.`
  String get info_share_book_description_collaborator {
    return Intl.message(
      'Le propriétaire du livre peut leur accorder plus de droits ou leurs retirer l\'accès à tout moment.',
      name: 'info_share_book_description_collaborator',
      desc: '',
      args: [],
    );
  }

  /// `Nouveau livre`
  String get book_creation_title {
    return Intl.message(
      'Nouveau livre',
      name: 'book_creation_title',
      desc: '',
      args: [],
    );
  }

  /// `Nom`
  String get book_creation_name {
    return Intl.message(
      'Nom',
      name: 'book_creation_name',
      desc: '',
      args: [],
    );
  }

  /// `Rejoindre un livre`
  String get book_join_title {
    return Intl.message(
      'Rejoindre un livre',
      name: 'book_join_title',
      desc: '',
      args: [],
    );
  }

  /// `ID du livre`
  String get book_join_uid {
    return Intl.message(
      'ID du livre',
      name: 'book_join_uid',
      desc: '',
      args: [],
    );
  }

  /// `Scan ID`
  String get book_join_scan {
    return Intl.message(
      'Scan ID',
      name: 'book_join_scan',
      desc: '',
      args: [],
    );
  }

  /// `Livre est déjà accessible`
  String get book_already_accessible {
    return Intl.message(
      'Livre est déjà accessible',
      name: 'book_already_accessible',
      desc: '',
      args: [],
    );
  }

  /// `Renommer le livre`
  String get book_rename_title {
    return Intl.message(
      'Renommer le livre',
      name: 'book_rename_title',
      desc: '',
      args: [],
    );
  }

  /// `Paramètres du livre`
  String get book_settings_page_title {
    return Intl.message(
      'Paramètres du livre',
      name: 'book_settings_page_title',
      desc: '',
      args: [],
    );
  }

  /// `Renommer`
  String get book_settings_rename {
    return Intl.message(
      'Renommer',
      name: 'book_settings_rename',
      desc: '',
      args: [],
    );
  }

  /// `Tags`
  String get book_settings_tags {
    return Intl.message(
      'Tags',
      name: 'book_settings_tags',
      desc: '',
      args: [],
    );
  }

  /// `Partager`
  String get book_settings_share {
    return Intl.message(
      'Partager',
      name: 'book_settings_share',
      desc: '',
      args: [],
    );
  }

  /// `Partager avec lien`
  String get book_settings_share_link {
    return Intl.message(
      'Partager avec lien',
      name: 'book_settings_share_link',
      desc: '',
      args: [],
    );
  }

  /// `Partager avec code QR`
  String get book_settings_share_qr {
    return Intl.message(
      'Partager avec code QR',
      name: 'book_settings_share_qr',
      desc: '',
      args: [],
    );
  }

  /// `Supprimer`
  String get book_settings_remove {
    return Intl.message(
      'Supprimer',
      name: 'book_settings_remove',
      desc: '',
      args: [],
    );
  }

  /// `Quitter`
  String get book_settings_quit {
    return Intl.message(
      'Quitter',
      name: 'book_settings_quit',
      desc: '',
      args: [],
    );
  }

  /// `Utilisateurs`
  String get book_settings_users {
    return Intl.message(
      'Utilisateurs',
      name: 'book_settings_users',
      desc: '',
      args: [],
    );
  }

  /// `Ajoute le livre `
  String get book_settings_share_content1 {
    return Intl.message(
      'Ajoute le livre ',
      name: 'book_settings_share_content1',
      desc: '',
      args: [],
    );
  }

  /// ` à `
  String get book_settings_share_content2 {
    return Intl.message(
      ' à ',
      name: 'book_settings_share_content2',
      desc: '',
      args: [],
    );
  }

  /// `Une connexion internet est nécessaire pour éditer les droits utilisateur.`
  String get book_settings_need_online {
    return Intl.message(
      'Une connexion internet est nécessaire pour éditer les droits utilisateur.',
      name: 'book_settings_need_online',
      desc: '',
      args: [],
    );
  }

  /// `Quels livres`
  String get recipe_page_book_picker_title {
    return Intl.message(
      'Quels livres',
      name: 'recipe_page_book_picker_title',
      desc: '',
      args: [],
    );
  }

  /// `Mise à jour`
  String get recipe_edition_update {
    return Intl.message(
      'Mise à jour',
      name: 'recipe_edition_update',
      desc: '',
      args: [],
    );
  }

  /// `Édition du temps`
  String get recipe_edition_time_title {
    return Intl.message(
      'Édition du temps',
      name: 'recipe_edition_time_title',
      desc: '',
      args: [],
    );
  }

  /// `Édition des tags`
  String get recipe_edition_tags_title {
    return Intl.message(
      'Édition des tags',
      name: 'recipe_edition_tags_title',
      desc: '',
      args: [],
    );
  }

  /// `Édition des ingrédients`
  String get recipe_edition_ingredients_title {
    return Intl.message(
      'Édition des ingrédients',
      name: 'recipe_edition_ingredients_title',
      desc: '',
      args: [],
    );
  }

  /// `Nouveau nom`
  String get recipe_edition_new_name {
    return Intl.message(
      'Nouveau nom',
      name: 'recipe_edition_new_name',
      desc: '',
      args: [],
    );
  }

  /// `qté`
  String get ingredient_quantity_edition {
    return Intl.message(
      'qté',
      name: 'ingredient_quantity_edition',
      desc: '',
      args: [],
    );
  }

  /// `Nouveau tag`
  String get new_tag_title {
    return Intl.message(
      'Nouveau tag',
      name: 'new_tag_title',
      desc: '',
      args: [],
    );
  }

  /// `Nom`
  String get new_tag_name {
    return Intl.message(
      'Nom',
      name: 'new_tag_name',
      desc: '',
      args: [],
    );
  }

  /// `Catégorie`
  String get new_tag_category {
    return Intl.message(
      'Catégorie',
      name: 'new_tag_category',
      desc: '',
      args: [],
    );
  }

  /// `notag`
  String get no_tag {
    return Intl.message(
      'notag',
      name: 'no_tag',
      desc: '',
      args: [],
    );
  }

  /// `Nouvel ingrédient`
  String get new_ingredient_title {
    return Intl.message(
      'Nouvel ingrédient',
      name: 'new_ingredient_title',
      desc: '',
      args: [],
    );
  }

  /// `Ingrédient`
  String get ingredient_edition_title {
    return Intl.message(
      'Ingrédient',
      name: 'ingredient_edition_title',
      desc: '',
      args: [],
    );
  }

  /// `Nom`
  String get ingredient_name {
    return Intl.message(
      'Nom',
      name: 'ingredient_name',
      desc: '',
      args: [],
    );
  }

  /// `Densité`
  String get ingredient_density {
    return Intl.message(
      'Densité',
      name: 'ingredient_density',
      desc: '',
      args: [],
    );
  }

  /// `Avancé`
  String get ingredient_advanced {
    return Intl.message(
      'Avancé',
      name: 'ingredient_advanced',
      desc: '',
      args: [],
    );
  }

  /// `Quantité`
  String get ingredient_quantity {
    return Intl.message(
      'Quantité',
      name: 'ingredient_quantity',
      desc: '',
      args: [],
    );
  }

  /// `Unité`
  String get ingredient_unit {
    return Intl.message(
      'Unité',
      name: 'ingredient_unit',
      desc: '',
      args: [],
    );
  }

  /// `Densité de l'ingrédient mise à jour`
  String get ingredient_density_updated {
    return Intl.message(
      'Densité de l\'ingrédient mise à jour',
      name: 'ingredient_density_updated',
      desc: '',
      args: [],
    );
  }

  /// `Créer un nouveau BookIngredient`
  String get ingredient_create_new_book_ingredient {
    return Intl.message(
      'Créer un nouveau BookIngredient',
      name: 'ingredient_create_new_book_ingredient',
      desc: '',
      args: [],
    );
  }

  /// `Réinitialiser`
  String get ingredient_reset_overrides {
    return Intl.message(
      'Réinitialiser',
      name: 'ingredient_reset_overrides',
      desc: '',
      args: [],
    );
  }

  /// `Sélectionne un ingrédient existant ou crée-en un nouveau`
  String get ingredient_select_or_create {
    return Intl.message(
      'Sélectionne un ingrédient existant ou crée-en un nouveau',
      name: 'ingredient_select_or_create',
      desc: '',
      args: [],
    );
  }

  /// `Modifier l'ingrédient maître`
  String get book_ingredient_edition_title {
    return Intl.message(
      'Modifier l\'ingrédient maître',
      name: 'book_ingredient_edition_title',
      desc: '',
      args: [],
    );
  }

  /// `Modifier l'ingrédient maître`
  String get ingredient_edit_book_ingredient {
    return Intl.message(
      'Modifier l\'ingrédient maître',
      name: 'ingredient_edit_book_ingredient',
      desc: '',
      args: [],
    );
  }

  /// `Autres`
  String get tag_category_other {
    return Intl.message(
      'Autres',
      name: 'tag_category_other',
      desc: '',
      args: [],
    );
  }

  /// `Ce tag est utilisé dans {count} recette(s) ("{name}"). La suppression le retirera de toutes ces recettes.`
  String tag_delete_used_warning(Object count, Object name) {
    return Intl.message(
      'Ce tag est utilisé dans $count recette(s) ("$name"). La suppression le retirera de toutes ces recettes.',
      name: 'tag_delete_used_warning',
      desc: '',
      args: [count, name],
    );
  }

  /// `Veux-tu quand même le supprimer ?`
  String get tag_delete_used_confirm {
    return Intl.message(
      'Veux-tu quand même le supprimer ?',
      name: 'tag_delete_used_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Étapes`
  String get steps_edition_title {
    return Intl.message(
      'Étapes',
      name: 'steps_edition_title',
      desc: '',
      args: [],
    );
  }

  /// `Étape`
  String get step_edition_title {
    return Intl.message(
      'Étape',
      name: 'step_edition_title',
      desc: '',
      args: [],
    );
  }

  /// `Décris l'étape ici...`
  String get step_edition_hint {
    return Intl.message(
      'Décris l\'étape ici...',
      name: 'step_edition_hint',
      desc: '',
      args: [],
    );
  }

  /// `Photos`
  String get images_edition_title {
    return Intl.message(
      'Photos',
      name: 'images_edition_title',
      desc: '',
      args: [],
    );
  }

  /// `Le nom est vide`
  String get error_name_empty {
    return Intl.message(
      'Le nom est vide',
      name: 'error_name_empty',
      desc: '',
      args: [],
    );
  }

  /// `Nouveau livre`
  String get book_add_dialog_title {
    return Intl.message(
      'Nouveau livre',
      name: 'book_add_dialog_title',
      desc: '',
      args: [],
    );
  }

  /// `Veux-tu créer un nouveau livre ou rejoindre un existant ?`
  String get book_add_dialog_description {
    return Intl.message(
      'Veux-tu créer un nouveau livre ou rejoindre un existant ?',
      name: 'book_add_dialog_description',
      desc: '',
      args: [],
    );
  }

  /// `Variantes`
  String get variant_widget_title {
    return Intl.message(
      'Variantes',
      name: 'variant_widget_title',
      desc: '',
      args: [],
    );
  }

  /// `Nouvelle variante`
  String get variant_widget_new {
    return Intl.message(
      'Nouvelle variante',
      name: 'variant_widget_new',
      desc: '',
      args: [],
    );
  }

  /// `Veux-tu vraiment supprimer cette variante ?`
  String get variant_remove_description {
    return Intl.message(
      'Veux-tu vraiment supprimer cette variante ?',
      name: 'variant_remove_description',
      desc: '',
      args: [],
    );
  }

  /// `Supprimer une variante`
  String get variant_remove_title {
    return Intl.message(
      'Supprimer une variante',
      name: 'variant_remove_title',
      desc: '',
      args: [],
    );
  }

  /// `Inscription`
  String get registration {
    return Intl.message(
      'Inscription',
      name: 'registration',
      desc: '',
      args: [],
    );
  }

  /// `Mauvais mot de passe`
  String get wrong_password {
    return Intl.message(
      'Mauvais mot de passe',
      name: 'wrong_password',
      desc: '',
      args: [],
    );
  }

  /// `Utilisateur non reconnu`
  String get wrong_user {
    return Intl.message(
      'Utilisateur non reconnu',
      name: 'wrong_user',
      desc: '',
      args: [],
    );
  }

  /// `Utilisateur déjà existant`
  String get existing_user {
    return Intl.message(
      'Utilisateur déjà existant',
      name: 'existing_user',
      desc: '',
      args: [],
    );
  }

  /// `Mot de passe trop simple`
  String get weak_password {
    return Intl.message(
      'Mot de passe trop simple',
      name: 'weak_password',
      desc: '',
      args: [],
    );
  }

  /// `J'ai perdu mon mot de passe`
  String get lost_password {
    return Intl.message(
      'J\'ai perdu mon mot de passe',
      name: 'lost_password',
      desc: '',
      args: [],
    );
  }

  /// `Page introuvable`
  String get page_not_found {
    return Intl.message(
      'Page introuvable',
      name: 'page_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Les Livres`
  String get onboarding_books_title {
    return Intl.message(
      'Les Livres',
      name: 'onboarding_books_title',
      desc: '',
      args: [],
    );
  }

  /// `Organisez vos recettes dans des livres. Créez-en plusieurs pour différentes occasions : quotidien, fêtes, voyages...`
  String get onboarding_books_desc {
    return Intl.message(
      'Organisez vos recettes dans des livres. Créez-en plusieurs pour différentes occasions : quotidien, fêtes, voyages...',
      name: 'onboarding_books_desc',
      desc: '',
      args: [],
    );
  }

  /// `Les Recettes`
  String get onboarding_recipes_title {
    return Intl.message(
      'Les Recettes',
      name: 'onboarding_recipes_title',
      desc: '',
      args: [],
    );
  }

  /// `Ajoutez vos recettes avec ingrédients, étapes de préparation, photos et variantes personnalisées.`
  String get onboarding_recipes_desc {
    return Intl.message(
      'Ajoutez vos recettes avec ingrédients, étapes de préparation, photos et variantes personnalisées.',
      name: 'onboarding_recipes_desc',
      desc: '',
      args: [],
    );
  }

  /// `Le Partage`
  String get onboarding_sharing_title {
    return Intl.message(
      'Le Partage',
      name: 'onboarding_sharing_title',
      desc: '',
      args: [],
    );
  }

  /// `Partagez vos livres avec vos proches. Choisissez les droits de chaque collaborateur : lecture, écriture ou administration.`
  String get onboarding_sharing_desc {
    return Intl.message(
      'Partagez vos livres avec vos proches. Choisissez les droits de chaque collaborateur : lecture, écriture ou administration.',
      name: 'onboarding_sharing_desc',
      desc: '',
      args: [],
    );
  }

  /// `C'est parti !`
  String get onboarding_ready_title {
    return Intl.message(
      'C\'est parti !',
      name: 'onboarding_ready_title',
      desc: '',
      args: [],
    );
  }

  /// `Choisissez votre langue et commencez à cuisiner !`
  String get onboarding_ready_desc {
    return Intl.message(
      'Choisissez votre langue et commencez à cuisiner !',
      name: 'onboarding_ready_desc',
      desc: '',
      args: [],
    );
  }

  /// `Suivant`
  String get onboarding_next {
    return Intl.message(
      'Suivant',
      name: 'onboarding_next',
      desc: '',
      args: [],
    );
  }

  /// `Passer`
  String get onboarding_skip {
    return Intl.message(
      'Passer',
      name: 'onboarding_skip',
      desc: '',
      args: [],
    );
  }

  /// `Commencer`
  String get onboarding_start {
    return Intl.message(
      'Commencer',
      name: 'onboarding_start',
      desc: '',
      args: [],
    );
  }

  /// `Recette introuvable. Vérifie que tu as bien accès à ce livre.`
  String get deeplink_recipe_not_found {
    return Intl.message(
      'Recette introuvable. Vérifie que tu as bien accès à ce livre.',
      name: 'deeplink_recipe_not_found',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
