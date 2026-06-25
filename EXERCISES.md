# Exercises — make the learning stick

Reading code teaches you less than *predicting* what it will do and then checking.
This file turns each section of the [README](README.md) into a few quick
active-recall prompts.

How to use it: work the section first, then come back. **Commit to an answer
before you run or reveal** — the prediction is where the learning happens. Answers
are hidden behind ▸ toggles.

> Example 01 is **(offline)** — no API call, no cost. The rest make small, cheap
> calls.

---

## Section 2 — What a tool is **(offline)**

**Recall.** When the model "uses a tool," does it run your function? What does it
actually do?

<details><summary>▸ Answer</summary>

No — the model never runs anything. It emits a *request*: a tool name plus
arguments. Your code decides whether and how to execute it. That gap is where all
of an agent's safety lives (approval, sandboxing, validation).
</details>

**Do (offline).** In `examples/01_tools.py`, the model only ever sees a tool's
name, description, and parameter schema — not the function body. Why does that
make the description a piece of prompt engineering?

<details><summary>▸ Answer</summary>

Because the description is the model's *only* basis for deciding when and how to
call the tool. A vague description ("does stuff") leads to misuse; a precise one
("use this for arithmetic; expression like '2+2'") leads to correct calls. You're
programming the model's behavior through that text.
</details>

---

## Section 3 — One tool call

**Predict, then run.** In `examples/02_one_tool_call.py`, you ask "What is 23 *
47?" with the calculator available. Will the model reply with the number, or with
something else?

<details><summary>▸ Answer</summary>

With a *tool call request* (calculator, expression="23 * 47"), not the number. It
defers the math to the tool. You then run it — and to turn that result into a
final answer you'd feed it back and ask again, which is the loop.
</details>

---

## Section 4 — The agent loop

**Recall.** Describe the agent loop in one sentence. What makes it stop?

<details><summary>▸ Answer</summary>

Ask the model; if it requests tools, run them, append the results, and ask again;
repeat until it responds with no tool calls — that final, tool-free response is
the answer. (A step cap is the backstop in case it never stops.)
</details>

**Do.** In `examples/03_agent_loop.py`, give it a question needing two or three
calculations and watch the trace. Does it make all the calls up front, or use each
result to decide the next?

<details><summary>▸ Answer</summary>

Usually one (or a few) at a time, using earlier results to inform later steps —
that step-by-step, result-dependent reasoning is exactly what the loop enables and
a single call can't do.
</details>

---

## Section 5 — Multiple tools

**Predict.** Give the agent `calculator` and `search_notes` and ask "what does the
Plus plan cost per year?" Which tool runs first, and why?

<details><summary>▸ Answer</summary>

search_notes first (to find the monthly price — a product fact), then calculator
(to multiply by 12). The model routes each sub-task to the tool whose description
fits. Nothing hard-codes that order; it's the model's choice, guided by the tool
descriptions.
</details>

---

## Section 6 — Limits & error recovery

**Recall.** Why feed a tool's *error* back to the model instead of crashing? And
what does `max_steps` protect against?

<details><summary>▸ Answer</summary>

Feeding the error back lets the model see what went wrong and adapt (retry with
different inputs, or explain) — robustness instead of a dead program. `max_steps`
protects against an infinite loop: a model that keeps calling tools and never
finishes would otherwise run forever (and run up a bill).
</details>

**Do.** Set `max_steps=1` on a task that clearly needs several steps. What does the
agent return, and what does `stopped_early` tell you?

<details><summary>▸ Answer</summary>

It returns a "stopped early" message and `stopped_early=True`, because it hit the
ceiling before reaching a final answer. That flag is how your code knows the result
is incomplete rather than a real answer.
</details>

---

## Section 7 — Human-in-the-loop

**Recall.** What makes a tool require approval, and what happens to the agent when
you deny one?

<details><summary>▸ Answer</summary>

You mark it `dangerous=True`; the loop then calls your `approve` callback before
running it. A denial is returned to the model as a normal tool result ("permission
denied"), so the agent acknowledges it and adapts instead of forcing the action.
</details>

---

## Section 8 — Observability

**Recall.** Why is a step trace essential for agents specifically, more than for a
single LLM call?

<details><summary>▸ Answer</summary>

Because an agent makes its own multi-step decisions — which tools, in what order,
with what arguments. When it goes wrong, the *why* is in that sequence. Without a
trace you're debugging a black box; with one you can see (and later eval) exactly
what it did.
</details>

---

## Section 9 — Memory

**Predict, then run.** In `examples/08_memory.py`, ask it to "search the plans,"
then ask "which is the cheapest paid one?" Does the second question work? Why?

<details><summary>▸ Answer</summary>

It works — because the same `history` list is passed back each turn, so the earlier
search and its results are still in the conversation the model sees. The API is
stateless; the memory is the growing list you choose to resend.
</details>

---

## Section 10 — Multi-agent

**Recall.** In `examples/09_multi_agent.py`, what *is* the research sub-agent, from
the orchestrator's point of view?

<details><summary>▸ Answer</summary>

Just another tool. Calling `research(question=...)` looks identical to calling any
tool — but its function body runs a second agent loop with its own prompt and
tools. Sub-agents are agents wrapped as tools; that's how large systems decompose.
</details>

---

## Capstone — `agent.py`

**Do.** Run `python hands_on/agent.py "Save a note titled 'todo' with body 'x'"`
and deny the approval prompt. Then run it again with `--yes`. Then add `--trace` to
either. You've now exercised the loop, the approval gate, and observability in one
tool.

**Stretch.** Add a new tool to `agent/tools.py` (say, a `word_count(text)` tool),
include it in `default_tools()`, and ask the capstone to use it. Adding a
capability is just: write a function, describe it, register it. That's the whole
extensibility story.

---

### Where to take it next

Invent your own. Wire one of your real functions in as a tool — something that
reads a file, hits an API you own, or queries a database — mark it dangerous if it
writes, and let the agent drive it. The first time an agent completes a multi-step
task you didn't script step-by-step, the idea has landed.
