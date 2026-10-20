class ConceptPair {
  final int id;
  final String concept;
  final String definition;
  final String feedback;
  final String category;

  const ConceptPair({
    required this.id,
    required this.concept,
    required this.definition,
    required this.feedback,
    required this.category,
  });
}

enum CardType { concept, definition }

class MemoryCardModel {
  final String uid;
  final int pairId;
  final CardType type;
  final String text;
  final ConceptPair pair;
  bool isFlipped;
  bool isMatched;
  bool isShaking;

  MemoryCardModel({
    required this.uid,
    required this.pairId,
    required this.type,
    required this.text,
    required this.pair,
    this.isFlipped = false,
    this.isMatched = false,
    this.isShaking = false,
  });
}

const List<ConceptPair> kAllConceptPairs = [
  ConceptPair(
    id: 1,
    concept: 'Inteligencia Artificial',
    definition: 'Agentes que perciben su entorno y actúan para lograr una meta.',
    feedback: 'Busca tomar la mejor decisión, no solo imitar humanos.',
    category: 'Fundamentos',
  ),
  ConceptPair(
    id: 2,
    concept: 'Test de Turing',
    definition: 'Chatear sin distinguir si responde un humano o una máquina.',
    feedback: 'Propuesto en 1950 para evaluar la conversación natural.',
    category: 'Fundamentos',
  ),
  ConceptPair(
    id: 3,
    concept: 'Agente Racional',
    definition: 'Elige siempre la acción que maximiza su éxito esperado.',
    feedback: 'Toma la mejor decisión con la información que tiene hoy.',
    category: 'Agentes',
  ),
  ConceptPair(
    id: 4,
    concept: 'PEAS',
    definition: 'Rendimiento, Entorno, Actuadores y Sensores de una IA.',
    feedback: 'Define qué hará el agente, dónde operará y cómo sentirá.',
    category: 'Agentes',
  ),
  ConceptPair(
    id: 5,
    concept: 'Totalmente Observable',
    definition: 'Los sensores ven todo lo necesario en todo momento.',
    feedback: 'Como en el ajedrez: ves todo el tablero sin usar memoria.',
    category: 'Entornos',
  ),
  ConceptPair(
    id: 6,
    concept: 'Entorno Dinámico',
    definition: 'El mundo cambia mientras la máquina piensa qué hacer.',
    feedback: 'Como conducir: el tráfico se mueve mientras decides.',
    category: 'Entornos',
  ),
  ConceptPair(
    id: 7,
    concept: 'Reflejo Simple',
    definition: 'Reacciona solo a lo que ve ahora, ignorando el pasado.',
    feedback: 'Usa reglas tipo: "si el auto de enfrente frena, yo freno".',
    category: 'Agentes',
  ),
  ConceptPair(
    id: 8,
    concept: 'Basado en Modelos',
    definition: 'Guarda memoria interna de lo que no puede ver ahora.',
    feedback: 'Vital cuando hay puntos ciegos en el entorno.',
    category: 'Agentes',
  ),
  ConceptPair(
    id: 9,
    concept: 'Basado en Metas',
    definition: 'Planea a futuro preguntándose: "¿Esto me acerca al destino?".',
    feedback: 'Si cambias la meta, recalcula su ruta automáticamente.',
    category: 'Agentes',
  ),
  ConceptPair(
    id: 10,
    concept: 'Búsqueda BFS',
    definition: 'Explora paso a paso por niveles, como olas en el agua.',
    feedback: 'Halla siempre la ruta más corta, pero usa mucha memoria.',
    category: 'Búsqueda',
  ),
  ConceptPair(
    id: 11,
    concept: 'Búsqueda DFS',
    definition: 'Sigue un camino hasta el fondo antes de retroceder.',
    feedback: 'Ahorra mucha memoria, pero puede caer en bucles.',
    category: 'Búsqueda',
  ),
  ConceptPair(
    id: 12,
    concept: 'Heurística',
    definition: 'Pista o estimación de cuánto falta para llegar a la meta.',
    feedback: 'Como medir la distancia en línea recta en un mapa.',
    category: 'Búsqueda',
  ),
  ConceptPair(
    id: 13,
    concept: 'Búsqueda A*',
    definition: 'Suma el camino recorrido más la estimación de lo que falta.',
    feedback: 'El algoritmo estrella para encontrar la ruta óptima.',
    category: 'Búsqueda',
  ),
  ConceptPair(
    id: 14,
    concept: 'Heurística Admisible',
    definition: 'Estimación optimista que nunca exagera el costo real.',
    feedback: 'Garantiza que A* encuentre siempre el camino más barato.',
    category: 'Búsqueda',
  ),
  ConceptPair(
    id: 15,
    concept: 'Deep Learning',
    definition: 'Redes neuronales de múltiples capas para tareas complejas.',
    feedback: 'Clave moderna en reconocimiento de voz, texto y visión.',
    category: 'Aprendizaje',
  ),
];
