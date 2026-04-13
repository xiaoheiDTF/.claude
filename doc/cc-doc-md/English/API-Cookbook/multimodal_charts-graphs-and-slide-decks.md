# Cookbook / Multimodal / Charts-Graphs-And-Slide-Decks

> 来源: claudecn.com

# Charts, graphs, and slide decks

Workflows for reading charts/graphs and slide decks, including ingestion and API calling patterns.

- Upstream notebook: multimodal/reading_charts_graphs_powerpoints.ipynb
## What to focus on

- Asking for explicit chart reading steps (axes, units, series)
- Extracting structured facts before generating narratives
- Handling multi-slide context vs per-slide analysis
## Run locally

```bash
make test-notebooks NOTEBOOK=multimodal/reading_charts_graphs_powerpoints.ipynb
```
