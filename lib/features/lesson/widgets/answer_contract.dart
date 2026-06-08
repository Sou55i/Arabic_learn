/// Contrat partagé entre le lecteur de leçon et les widgets d'exercice.
///
/// Chaque widget d'exercice signale, à chaque interaction, si une réponse
/// complète est prête (`ready`) et si elle est correcte (`correct`).
/// Le lecteur décide ensuite quand la valider (bouton « Vérifier »).
typedef AnswerCallback = void Function(({bool ready, bool correct}) result);
