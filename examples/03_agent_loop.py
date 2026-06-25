"""
Example 03 — the agent loop. This is the whole idea.
====================================================

Example 02 did one turn by hand. An agent just repeats it: run the tool, feed the
result back, ask again — until the model stops asking and gives a final answer.
That loop is `run_agent` (see agent/loop.py, ~20 lines).

We give it a question that needs several steps of arithmetic, turn on the Tracer
so you can watch each tool call, and print the final answer. Notice the model
chains calls: it uses one result to decide the next.

Run it:

    python examples/03_agent_loop.py
    python examples/03_agent_loop.py "What is 15% of 240, plus 7 squared?"
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from dotenv import load_dotenv

import agent

load_dotenv()
agent.ensure_ready()
print(f"Provider: {agent.describe()}\n")

SYSTEM = "You are a careful assistant. Use the calculator for any arithmetic — don't compute in your head."

question = sys.argv[1] if len(sys.argv) > 1 else "What is (23 * 47) + (88 / 4), and then that total multiplied by 3?"
print(f"Question: {question}\n")
print("Trace:")

result = agent.run_agent(SYSTEM, question, [agent.CALCULATOR], tracer=agent.Tracer())

print(f"\nFinal answer: {result.answer}")
print(f"({len(result.steps)} tool call(s) along the way)")

print(
    "\nThat's an agent: a loop around tool-calling. Everything from here — more "
    "tools, error recovery, approval, memory, sub-agents — is a small addition to "
    "this loop, not a new concept."
)
