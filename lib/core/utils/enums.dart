enum DevisStatus { brouillon, envoye, accepte, refusee, expire }
enum FactureStatus { impayee, partielle, payee, annulee }
enum ChantierStatus { planifie, enCours, enPause, termine, annule }
enum PaiementMode { especes, virement, carteMobile, cheque, carteBancaire }
enum ClientCategory { particulier, entreprise, artisan, institution }
enum Unite { piece, metre, heure, jour, kg, litre, boite, rouleau, pack, kit }
enum BackupStatus { idle, inProgress, success, error }
enum SyncStatus { synced, pending, conflict }
