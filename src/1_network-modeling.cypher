// --- REDE BIPARTIDA ---
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

// Projeta a rede bipartida para armazenamento no catálogo de grafos
CALL gds.graph.project(
    'BipartiteNetwork',
    ['MicroRNA', 'MessengerRNA'],
    {
        INTERACTS_WITH: {
            orientation: 'UNDIRECTED'
        }
    }
)

// --- REDE PROJETADA SOBRE OS microRNAS ---
// Projeta a rede bipartida com base nos RNAs mensageiros
MATCH (mirnaA:MicroRNA)-[:INTERACTS_WITH]->(mrna:MessengerRNA)
MATCH (mirnaB:MicroRNA)-[:INTERACTS_WITH]->(mrna:MessengerRNA)
WHERE mirnaA.id < mirnaB.id
WITH mirnaA, mirnaB, COUNT(mrna) AS commonMrnas
MERGE (mirnaA)-[r:IS_RELATED_TO]-(mirnaB)
SET r.commonMrnas = commonMrnas;

// Mostra a rede projetada
MATCH (mirnaA:MicroRNA)-[r:IS_RELATED_TO]->(mirnaB:MicroRNA)
RETURN mirnaA, r, mirnaB;

// Projeta a rede de microRNAs para armazenamento no catálogo de grafos
CALL gds.graph.project(
    'ProjectedNetwork',
    'MicroRNA',
    {
        IS_RELATED_TO: {
            orientation: 'UNDIRECTED',
            properties: ['commonMrnas']
        }
    }
)