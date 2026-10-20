# Memorama Interactivo de Fundamentos de IA 🧠🃏

Juego educativo digital desarrollado en **Flutter Web**, diseñado con un enfoque **mobile-first y responsivo** para enseñar los conceptos fundamentales de agentes inteligentes, entornos y algoritmos de búsqueda en Inteligencia Artificial.

## Características Principales

- **Tablero de 30 Cartas (15 Pares):** Empareja cada **Concepto** (tarjetas moradas) con su **Definición Simplificada** (tarjetas azules).
- **Sistema de Puntuación y Rachas:**
  - `+10 puntos` base por cada par correcto.
  - Multiplicador de **racha consecutiva** (`10 × racha` puntos cuando encadenas aciertos sin fallar).
- **Retroalimentación Visual e Inmediata:**
  - **Al acertar:** Animación de confirmación y banner con un dato curioso / explicación del concepto.
  - **Al fallar:** Las cartas tiemblan en pantalla (`shake animation`) y aparece un globo explicando por qué no coinciden junto con una pista de aprendizaje.
- **Diseño Responsivo (Mobile-First):**
  - **Teléfonos (`< 480px`):** Cuadrícula de 3 columnas optimizada para pantallas verticales táctiles, con vista ampliada al tocar cualquier carta volteada.
  - **Tablets (`480px - 840px`):** Cuadrícula de 5 columnas.
  - **Escritorio (`> 840px`):** Cuadrícula de 6×5.
- **Glosario Integrado:** Consulta en cualquier momento los 15 conceptos, sus definiciones y datos clave, viendo cuáles ya desbloqueaste en tu partida.

## Cómo Ejecutar Localmente

```bash
flutter pub get
flutter run -d web-server
```

## Cómo Compilar para GitHub Pages

El proyecto ya incluye un flujo de trabajo automatizado en [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml) que compila y despliega automáticamente en **GitHub Pages** al hacer `push` a la rama `main` o `master`.

Para compilar manualmente:

```bash
flutter build web --release --base-href "/NOMBRE_DE_TU_REPO/"
```
