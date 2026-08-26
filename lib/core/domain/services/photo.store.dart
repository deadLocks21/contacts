/// Port de stockage des photos de contact.
///
/// Le fichier choisi par l'utilisateur (galerie, appareil photo) vit dans un
/// cache que le système peut vider : on le **recopie** dans l'espace de l'app
/// et c'est ce chemin-là que porte le contact.
abstract interface class PhotoStore {
  /// Recopie [sourcePath] dans l'espace de l'app et renvoie le chemin retenu.
  Future<String> persist(String sourcePath, String contactId);

  /// Supprime une photo devenue orpheline. Silencieux si le fichier n'existe plus.
  Future<void> remove(String path);
}
