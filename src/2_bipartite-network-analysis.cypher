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

// --- CENTRALIDADES ---
// Calcula a centralidade de grau dos nós
CALL gds.degree.stream('BipartiteNetwork')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS molecule, score AS degree
ORDER BY degree DESC, molecule ASC;

// Calcula a centralidade de intermediação dos nós
CALL gds.betweenness.stream('BipartiteNetwork')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS molecule, score AS betweenness
ORDER BY betweenness DESC, molecule ASC;

// Calcula a centralidade de autovetor dos nós
CALL gds.eigenvector.stream('BipartiteNetwork')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS molecule, score AS eigenvector
ORDER BY eigenvector DESC, molecule ASC;

// Calcula a centralidade de proximidade dos nós
CALL gds.closeness.stream('BipartiteNetwork')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS molecule, score AS closeness
ORDER BY closeness DESC, molecule ASC;

// Identifica os pontos de articulação da rede
CALL gds.articulationPoints.stream('BipartiteNetwork')
YIELD nodeId
RETURN gds.util.asNode(nodeId).id AS molecule
ORDER BY molecule ASC;

// Identifica as pontes da rede
CALL gds.bridges.stream('BipartiteNetwork')
YIELD from, to
RETURN gds.util.asNode(from).id AS from, gds.util.asNode(to).id AS to
ORDER BY from ASC, to ASC;

// --- DETECÇÃO DE COMUNIDADES ---
// Calcula a quantidade de triângulos na rede
CALL gds.triangleCount.stream('BipartiteNetwork')
YIELD nodeId, triangleCount
RETURN gds.util.asNode(nodeId).id AS molecule, triangleCount
ORDER BY triangleCount DESC, molecule ASC;

// Calcula o máximo k-corte aproximado da rede
CALL gds.maxkcut.stream('BipartiteNetwork')
YIELD nodeId, communityId
RETURN gds.util.asNode(nodeId).id AS molecule, communityId
ORDER BY communityId DESC, molecule ASC;
