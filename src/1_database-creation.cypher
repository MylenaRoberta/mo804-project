// Limpa o banco de dados
MATCH (n) DETACH DELETE (n);

// Lê o arquivo CSV de microRNAs
LOAD CSV WITH HEADERS FROM 
    'https://raw.githubusercontent.com/MylenaRoberta/mo804-project/refs/heads/main/data/processed/miRWalk-data/mirnas.csv' 
    AS row
MERGE (:MicroRNA {id: row.mirnaid});

// Lê o arquivo CSV de RNAs mensageiros
LOAD CSV WITH HEADERS FROM 
    'https://raw.githubusercontent.com/MylenaRoberta/mo804-project/refs/heads/main/data/processed/miRWalk-data/mrnas.csv' 
    AS row
MERGE (:MessengerRNA {id: row.refseqid, geneSymbol: row.genesymbol});

// Lê o arquivo CSV de interações microRNA-RNA mensageiro
CREATE INDEX mirna_id IF NOT EXISTS FOR (mirna:MicroRNA) ON (mirna.id);
CREATE INDEX mrna_id IF NOT EXISTS FOR (mrna:MessengerRNA) ON (mrna.id);
LOAD CSV WITH HEADERS FROM 
    'https://raw.githubusercontent.com/MylenaRoberta/mo804-project/refs/heads/main/data/processed/miRWalk-data/interactions.csv'
    AS row
MERGE (mirna:MicroRNA {id: row.mirnaid})
MERGE (mrna:MessengerRNA {id: row.refseqid})
MERGE (mirna)-[:INTERACTS_WITH {
    pValue: row.bindingp,
    targetScan: row.TargetScan,
    miRDB: row.miRDB,
    mirTarBase: row.miRTarBase
}]->(mrna);

// Mostra a rede parcialmente
MATCH (mirna:MicroRNA)-[r:INTERACTS_WITH]->(mrna:MessengerRNA)
RETURN mirna, r, mrna
LIMIT 300;