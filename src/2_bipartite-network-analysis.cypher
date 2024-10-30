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
ORDER BY degree DESC, molecule DESC

// Calcula a centralidade de intermediação dos nós
CALL gds.betweenness.stream('BipartiteNetwork')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS molecule, score AS betweenness
ORDER BY betweenness DESC, molecule DESC

// Calcula a centralidade de autovetor dos nós
CALL gds.eigenvector.stream('BipartiteNetwork')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS molecule, score AS eigenvector
ORDER BY eigenvector DESC, molecule DESC

// Calcula a centralidade de proximidade dos nós
CALL gds.closeness.stream('BipartiteNetwork')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS molecule, score AS closeness
ORDER BY closeness DESC, molecule DESC
