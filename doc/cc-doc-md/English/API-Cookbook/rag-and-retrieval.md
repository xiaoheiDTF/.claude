# Cookbook / Rag-And-Retrieval

> 来源: claudecn.com

# Capabilities: RAG & Retrieval

This section becomes important when “just putting documents into context” stops being enough. The goal is not to force one architecture. The goal is to help you answer a more practical question: how far does retrieval need to go before answers become reliably grounded for your use case?

## Choose a path by problem complexity

### You only need relevant passages

Start with basic RAG. It is the right first move when the problem is simply finding the right supporting content and letting the model assemble the answer.

### Retrieved chunks lose too much context

If the chunks you retrieve are often technically relevant but hard to interpret on their own, move into contextual retrieval. The point is not more complexity for its own sake. The point is making retrieved content easier to use correctly.

### The problem is about relationships, not similar passages

When the task becomes “who is connected to whom” or “how do these entities relate,” knowledge graphs often make more sense than continuing to scale plain vector retrieval.

### Recall and precision keep fighting each other

If you already retrieve enough material but ranking is noisy or unstable, it is time to think about hybrid retrieval, reranking, and evaluation.

## What this section helps you do

- add traceable grounding to model answers
- move retrieval from “works sometimes” toward “works more consistently”
- decide when to deepen RAG and when to switch to a more structured representation
- build a base for citations, evaluation, and quality regression
## Suggested reading order

- Start with Retrieval Augmented Generation for the core baseline
- Continue to Contextual Retrieval when chunks need more context
- Move to Knowledge Graph when the real task is relationship reasoning
- Add hybrid retrieval, reranking, and evaluation when quality demands become stricter
## Related capability extensions
[Knowledge GraphUse a structured representation when entity relationships matter
](knowledge-graph/)[Text to SQLTurn language into queries instead of relying only on retrieved passages
](text-to-sql/)[SummarizationSummarize long or multi-source material more reliably
](summarization/)[ClassificationRoute work through classification before retrieval or downstream handling
](classification/)
