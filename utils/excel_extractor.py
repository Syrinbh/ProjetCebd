import sqlite3, pandas
from sqlite3 import IntegrityError

# Fonction permettant de lire le fichier Excel des JO et d'insérer les données dans la base
def read_excel_file_V0(data:sqlite3.Connection, file):
    # Lecture de l'onglet du fichier excel LesSportifsEQ, en interprétant toutes les colonnes comme des strings
    # pour construire uniformement la requête
# ---------------------------------------------
# INSERT LesSportifs
# ---------------------------------------------
    df_sportifs = pandas.read_excel(file, sheet_name='LesSportifsEQ', dtype=str)
    df_sportifs = df_sportifs.where(pandas.notnull(df_sportifs), 'null')

    cursor = data.cursor()
    for ix, row in df_sportifs.iterrows():
        try:
            query = "insert or ignore into LesSportifs values ('{}','{}','{}','{}','{}','{}')".format(
                row['numSp'], row['nomSp'], row['prenomSp'], row['dateNaisSp'], row['categorieSp'], row['pays'])
            # On affiche la requête pour comprendre la construction. A enlever une fois compris.
            print(query)
            cursor.execute(query)
        except IntegrityError as err:
            print(err)

    # Lecture de l'onglet LesEpreuves du fichier excel, en interprétant toutes les colonnes comme des string
    # pour construire uniformement la requête

# ---------------------------------------------
# INSERT LesEquipes 
# ---------------------------------------------

    df_equipes = pandas.read_excel(file, sheet_name='LesSportifsEQ', dtype=str)
    df_equipes = df_equipes.where(pandas.notnull(df_equipes), 'null')

    cursor = data.cursor()
    for ix, row in df_equipes.iterrows():
        try:
            if row['numEq'] == 'null':
                continue
            query = "insert or ignore into LesEquipes values ('{}')".format(row['numEq'])
            print(query)
            cursor.execute(query)  # Pas de paramètres
        except IntegrityError as err:
            print(f"{err} : \n{row}")




# ---------------------------------------------
# INSERT LesMembresEquipes 
# ---------------------------------------------
    df_membres_equipes = pandas.read_excel(file, sheet_name='LesSportifsEQ', dtype=str)
    df_membres_equipes = df_membres_equipes.where(pandas.notnull(df_membres_equipes), 'null')

    cursor = data.cursor()
    for ix, row in df_membres_equipes.iterrows():
        try:
            if row['numEq'] != 'null':
                query = "insert or ignore into LesMembresEquipes values ('{}','{}')".format(
                    row['numEq'],row['numSp'])

                # On affiche la requête pour comprendre la construction. A enlever une fois compris.
                print(query)
                cursor.execute(query)
        except IntegrityError as err:
            print(f"{err} : \n{row}") 

# ---------------------------------------------
# INSERT LesEpreuvesIndividuelles ET LesEpreuvesParEquipe
# ---------------------------------------------
    df_epreuves = pandas.read_excel(file, sheet_name='LesEpreuves', dtype=str)
    df_epreuves = df_epreuves.where(pandas.notnull(df_epreuves), 'null')
    forme_par_ep = dict(zip(df_epreuves['numEp'], df_epreuves['formeEp']))


    cursor = data.cursor()
    for ix, row in df_epreuves.iterrows():
        try:
            if row['formeEp'] == 'individuelle':
                query = "insert into LesEpreuvesIndividuelles values ('{}','{}','{}','{}','{}')".format(
                    row['numEp'], row['nomEp'], row['categorieEp'], row['dateEp'], row['nomDi'])
            else:
                query = "insert into LesEpreuvesParEquipe values ('{}','{}','{}','{}','{}','{}')".format(
                row['numEp'], row['nomEp'], row['categorieEp'], row['dateEp'], row['formeEp'] ,row['nomDi'])
            # On affiche la requête pour comprendre la construction. A enlever une fois compris.
            print(query)
            cursor.execute(query)
        except IntegrityError as err:
            print(f"{err} : \n{row}")



# ---------------------------------------------
# INSERT LesInscriptionsEpreuvesIndividuelles et LesInscriptionsEpreuvesParEquipes 
# ---------------------------------------------

    df_ins = pandas.read_excel(file, sheet_name='LesInscriptions', dtype=str)
    df_ins = df_ins.where(pandas.notnull(df_ins), 'null')

    cursor = data.cursor()
    for ix, row in df_ins.iterrows():
        try:
            numEp = row['numEp']
            numIn = row['numIn']
            forme = forme_par_ep.get(numEp)  # 'individuelle' ou 'par equipe' / 'par couple'

            if forme == 'individuelle':
                # numIn = idS
                query = "insert or ignore into LesInscriptionsEpreuvesIndividuelles values ('{}', '{}')".format(numEp, numIn)
                print(query)
                cursor.execute(query) 
            else:
                # numIn = idEq
                query = "insert or ignore into LesInscriptionsEpreuvesParEquipes values ('{}', '{}')".format(numEp, numIn)
                print(query)
                cursor.execute(query)
        except IntegrityError as err:
            print(f"{err} : \n{row}")




# ---------------------------------------------
# INSERT LesMedaillesIndividuelle 
# ---------------------------------------------
    df_medailles = pandas.read_excel(file, sheet_name='LesResultats', dtype=str)
    df_medailles = df_medailles.where(pandas.notnull(df_medailles), 'null')

    cursor = data.cursor()
    for ix, row in df_medailles.iterrows():
        try:
            numEp = row['numEp'] 
            forme = forme_par_ep.get(numEp) 
            
            if forme == 'individuelle':
                query = "insert into LesMedaillesIndividuelle values ('{}','{}','{}','{}')".format(
                    numEp, row['gold'], row['silver'], row['bronze'])
                print(query)
                cursor.execute(query)
            else:
                query = "insert into LesMedaillesEquipe values ('{}','{}','{}','{}')".format(
                    numEp, row['gold'], row['silver'], row['bronze'])
                print(query)
                cursor.execute(query)
        except (KeyError, IntegrityError) as err:
            print(f"{err} : \n{row}")
