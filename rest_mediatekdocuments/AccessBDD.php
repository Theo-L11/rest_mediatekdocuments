<?php

include_once("ConnexionPDO.php");

/**
 * Classe de construction des requêtes SQL à envoyer à la BDD
 */
class AccessBDD {

    public $login = "root";
    public $mdp = "";
    public $bd = "mediatek86";
    public $serveur = "localhost";
    public $port = "3308";
    public $conn = null;

    /**
     * constructeur : demande de connexion à la BDD
     */
    public function __construct() {
        try {
            $this->conn = new ConnexionPDO($this->login, $this->mdp, $this->bd, $this->serveur, $this->port);
        } catch (Exception $e) {
            throw $e;
        }
    }

    /**
     * récupération de toutes les lignes d'une table
     * @param string $table nom de la table
     * @return lignes de la requete
     */
    public function selectAll($table) {
        if ($this->conn != null) {
            switch ($table) {
                case "livre" :
                    return $this->selectAllLivres();
                case "dvd" :
                    return $this->selectAllDvd();
                case "revue" :
                    return $this->selectAllRevues();
                case "exemplaire" :
                    return $this->selectExemplairesRevue();
                case "genre" :
                case "public" :
                case "rayon" :
                case "etat" :
                    // select portant sur une table contenant juste id et libelle
                    return $this->selectTableSimple($table);
                default:
                    // select portant sur une table, sans condition
                    return $this->selectTable($table);
            }
        } else {
            return null;
        }
    }

    /**
     * récupération des lignes concernées
     * @param string $table nom de la table
     * @param array $champs nom et valeur de chaque champs de recherche
     * @return lignes répondant aux critères de recherches
     */
    public function select($table, $champs) {
        if ($this->conn != null && $champs != null) {
            switch ($table) {
                case "exemplaire" :
                    return $this->selectExemplairesRevue($champs['id']);
                case "commandedocument" :
                    return $this->selectCommandeDocument($champs['id']);
                case "abonnement" :
                    return $this->selectAbonnementRevue($champs['id']);
                case "expirationabonnements" :
                    return $this->selectExpirationAbonnements($champs['date']);
                case "utilisateur" :
                    return $this->selectUtilisateur($champs['nom']);
                default:
                    // cas d'un select sur une table avec recherche sur des champs
                    return $this->selectTableOnConditons($table, $champs);
            }
        } else {
            return null;
        }
    }

    /**
     * récupération de toutes les lignes d'une table simple (qui contient juste id et libelle)
     * @param string $table
     * @return lignes triées sur lebelle
     */
    public function selectTableSimple($table) {
        $req = "select * from $table order by libelle;";
        return $this->conn->query($req);
    }

    /**
     * récupération de toutes les lignes d'une table
     * @param string $table
     * @return toutes les lignes de la table
     */
    public function selectTable($table) {
        $req = "select * from $table;";
        return $this->conn->query($req);
    }

    /**
     * récupération des lignes d'une table dont les champs concernés correspondent aux valeurs
     * @param type $table
     * @param type $champs
     * @return type
     */
    public function selectTableOnConditons($table, $champs) {
        // construction de la requête
        $requete = "select * from $table where ";
        foreach ($champs as $key => $value) {
            $requete .= "$key=:$key and";
        }
        // (enlève le dernier and)
        $requete = substr($requete, 0, strlen($requete) - 3);
        return $this->conn->query($requete, $champs);
    }

    /**
     * récupération de toutes les lignes de la table Livre et les tables associées
     * @return lignes de la requete
     */
    public function selectAllLivres() {
        $req = "Select l.id, l.ISBN, l.auteur, d.titre, d.image, l.collection, ";
        $req .= "d.idrayon, d.idpublic, d.idgenre, g.libelle as genre, p.libelle as lePublic, r.libelle as rayon ";
        $req .= "from livre l join document d on l.id=d.id ";
        $req .= "join genre g on g.id=d.idGenre ";
        $req .= "join public p on p.id=d.idPublic ";
        $req .= "join rayon r on r.id=d.idRayon ";
        $req .= "order by titre ";
        return $this->conn->query($req);
    }

    /**
     * récupération de toutes les lignes de la table DVD et les tables associées
     * @return lignes de la requete
     */
    public function selectAllDvd() {
        $req = "Select l.id, l.duree, l.realisateur, d.titre, d.image, l.synopsis, ";
        $req .= "d.idrayon, d.idpublic, d.idgenre, g.libelle as genre, p.libelle as lePublic, r.libelle as rayon ";
        $req .= "from dvd l join document d on l.id=d.id ";
        $req .= "join genre g on g.id=d.idGenre ";
        $req .= "join public p on p.id=d.idPublic ";
        $req .= "join rayon r on r.id=d.idRayon ";
        $req .= "order by titre ";
        return $this->conn->query($req);
    }

    /**
     * récupération de toutes les lignes de la table Revue et les tables associées
     * @return lignes de la requete
     */
    public function selectAllRevues() {
        $req = "Select l.id, l.periodicite, d.titre, d.image, l.delaiMiseADispo, ";
        $req .= "d.idrayon, d.idpublic, d.idgenre, g.libelle as genre, p.libelle as lePublic, r.libelle as rayon ";
        $req .= "from revue l join document d on l.id=d.id ";
        $req .= "join genre g on g.id=d.idGenre ";
        $req .= "join public p on p.id=d.idPublic ";
        $req .= "join rayon r on r.id=d.idRayon ";
        $req .= "order by titre ";
        return $this->conn->query($req);
    }

    /**
     * récupération de tous les exemplaires d'une revue
     * @param string $id id de la revue
     * @return lignes de la requete
     */
    public function selectExemplairesRevue($id) {
        $param = array(
            "id" => $id
        );
        $req = "Select e.id, e.numero, e.dateAchat, e.photo, e.idEtat ";
        $req .= "from exemplaire e join document d on e.id=d.id ";
        $req .= "where e.id = :id ";
        $req .= "order by e.dateAchat DESC";
        return $this->conn->query($req, $param);
    }

    /*     * public function selectCommandeDocument($id){
      $param = array(
      "id" => $id
      );
      $req = "Select c.id, c.dateCommande, c.montant, cd.id, cd.nbExemplaire, cd.idLivreDvd, cd.idEtape, s.etape ";
      $req .= "from commandedocument cd join commande c on cd.id = c.id ";
      $req .= "join suivi s on cd.idEtape = s.id ";
      $req .= "where cd.idLivreDvd = :id;";
      return $this->conn->query($req, $param);
      }* */

    public function selectCommandeDocument($id) {
        $param = array(
            "id" => $id
        );
        $req = "Select c.dateCommande, c.montant, cd.id, cd.idLivreDvd, cd.nbExemplaire, cd.idEtape, s.etape ";
        $req .= "from commandedocument cd join commande c on cd.id = c.id ";
        $req .= "join suivi s on cd.idEtape = s.id ";
        $req .= "where cd.idLivreDvd = :id;";
        return $this->conn->query($req, $param);
    }

    public function selectExpirationAbonnements($date) {
        
        $req = "SELECT a.dateFinAbonnement, d.titre ";
        $req .= "FROM abonnement a JOIN document d ON a.idRevue = d.id ";
        $req .= "WHERE dateFinAbonnement BETWEEN :date AND DATE_ADD(:date, INTERVAL 30 DAY);";

        $param = array(
            "date" => $date
        );
        return $this->conn->query($req, $param);
    }

    public function selectAbonnementRevue($id) {
        $param = array(
            "id" => $id
        );
        $req = "select a.id, r.id as idRevue, c.dateCommande, c.montant, a.dateFinAbonnement ";
        $req .= "from commande c join abonnement a on c.id = a.id ";
        $req .= "join revue r on a.idRevue = r.id ";
        $req .= "where r.id = :id;";
        return $this->conn->query($req, $param);
    }
    
    public function selectUtilisateur($nom){
        $param = array(
            "nom" => $nom
        );
        $req = "select * from utilisateur where nom = :nom";
        return $this->conn->query($req, $param);
    }

    /**
     * Ajout d'une ligne dans deux tables (Commande et Commandedocument)
     * @param array $champs Valeurs des propriétés de CommandeDocument
     * @return true si l'ajout a fonctionné, sinon false
     */
    public function insertCommandeDocument($champs) {
        if ($this->conn != null && $champs != null) {

            // Insert dans la table Commande
            $requeteCommande = "INSERT INTO commande (id, dateCommande, montant) VALUES (:Id, :DateCommande, :Montant)";

            $param = array(
                "Id" => $champs["Id"],
                "DateCommande" => $champs["DateCommande"],
                "Montant" => $champs["Montant"]
            );
            $this->conn->execute($requeteCommande, $param);

            // Insert dans la table Commandedocument
            $requeteCommandeDocument = "INSERT INTO commandedocument (id, idLivreDvd, nbExemplaire, idEtape) VALUES (:Id, :IdLivreDvd, :NbExemplaire, :IdEtape)";

            $param = array(
                "Id" => $champs["Id"],
                "IdLivreDvd" => $champs["IdLivreDvd"],
                "NbExemplaire" => $champs["NbExemplaire"],
                "IdEtape" => $champs["IdEtape"]
            );
            return $this->conn->execute($requeteCommandeDocument, $param);
        } else {
            return null;
        }
    }

    public function insertAbonnement($champs) {
        if ($this->conn != null && $champs != null) {

            // Insert dans la table Commande
            $requeteCommande = "INSERT INTO commande (id, dateCommande, montant) VALUES (:Id, :DateCommande, :Montant)";

            $param = array(
                "Id" => $champs["Id"],
                "DateCommande" => $champs["DateCommande"],
                "Montant" => $champs["Montant"]
            );
            $this->conn->execute($requeteCommande, $param);

            // Insert dans la table Commandedocument
            $requeteAbonnement = "INSERT INTO abonnement (id, dateFinAbonnement, idRevue) VALUES (:Id, :DateFinAbonnement, :IdRevue)";

            $param = array(
                "Id" => $champs["Id"],
                "DateFinAbonnement" => $champs["DateFinAbonnement"],
                "IdRevue" => $champs["IdRevue"]
            );
            return $this->conn->execute($requeteAbonnement, $param);
        } else {
            return null;
        }
    }

    public function deleteAbonnement($champs) {
        if ($this->conn != null && $champs != null) {

            $requeteAbonnement = "delete from abonnement where id=:Id";
            $param = array(
                "Id" => $champs["Id"]
            );
            $this->conn->execute($requeteAbonnement, $param);

            $requeteCommande = "delete from commande where id=:Id";
            $param = array(
                "Id" => $champs["Id"]
            );
            return $this->conn->execute($requeteCommande, $param);
        } else {
            return null;
        }
    }

    public function delete($table, $champs) {
        if ($this->conn != null) {
            // construction de la requête
            $requete = "delete from $table where ";
            foreach ($champs as $key => $value) {
                $requete .= "$key=:$key and ";
            }
            // (enlève le dernier and)
            $requete = substr($requete, 0, strlen($requete) - 5);
            return $this->conn->execute($requete, $champs);
        } else {
            return null;
        }
    }

    /**
     * ajout d'une ligne dans une table
     * @param string $table nom de la table
     * @param array $champs nom et valeur de chaque champs de la ligne
     * @return true si l'ajout a fonctionné
     */
    public function insertOne($table, $champs) {
        if ($this->conn != null && $champs != null) {
            // construction de la requête
            $requete = "insert into $table (";
            foreach ($champs as $key => $value) {
                $requete .= "$key,";
            }
            // (enlève la dernière virgule)
            $requete = substr($requete, 0, strlen($requete) - 1);
            $requete .= ") values (";
            foreach ($champs as $key => $value) {
                $requete .= ":$key,";
            }
            // (enlève la dernière virgule)
            $requete = substr($requete, 0, strlen($requete) - 1);
            $requete .= ");";
            return $this->conn->execute($requete, $champs);
        } else {
            return null;
        }
    }

    /**
     * modification d'une ligne dans une table
     * @param string $table nom de la table
     * @param string $id id de la ligne à modifier
     * @param array $param nom et valeur de chaque champs de la ligne
     * @return true si la modification a fonctionné
     */
    public function updateOne($table, $id, $champs) {
        if ($this->conn != null && $champs != null) {
            // construction de la requête
            $requete = "update $table set ";
            foreach ($champs as $key => $value) {
                $requete .= "$key=:$key,";
            }
            // (enlève la dernière virgule)
            $requete = substr($requete, 0, strlen($requete) - 1);
            $champs["id"] = $id;
            $requete .= " where id=:id;";
            return $this->conn->execute($requete, $champs);
        } else {
            return null;
        }
    }

}
