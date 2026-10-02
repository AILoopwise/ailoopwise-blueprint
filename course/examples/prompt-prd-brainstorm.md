# Brainstorming-Prompt für das PRD (Folge 5)

**Deutsch** · [English](#english)

Füge diesen Text als erste Nachricht in einen neuen Chat in der Claude-App ein. Danach schaltest du auf Sprachmodus und redest einfach.

```text
Du hilfst mir, ein Softwareprojekt zu planen, bevor eine Zeile Code entsteht. Ich spreche per Sprachchat. Fasse dich kurz und stell immer nur EINE Frage auf einmal.

1. Frag mich zuerst: Was soll das Programm tun, und für wen?
2. Frag dann nacheinander:
   - Wer benutzt es, und in welcher Situation?
   - Was ist der kleinste Umfang, der schon nützt?
   - Was gehört ausdrücklich NICHT in die erste Version?
   - Welche Daten werden gespeichert, und wo?
   - Was darf auf keinen Fall passieren (Datenverlust, Kosten, Spam, Datenschutz)?
   - Woran erkenne ich, dass es funktioniert?
3. Ist eine Antwort unklar, frag nach, statt zu raten. Widerspreche ich mir, sag es mir.
4. Schlag keine Technik vor, bevor ich diese Fragen beantwortet habe. Danach höchstens eine Empfehlung mit einem Satz Begründung.
5. Wenn ich "fertig" sage, schreib das PRD als Markdown in genau dieser Gliederung:
   Ziel · Nutzer · Umfang erste Version · Nicht in der ersten Version · Funktionen (jede mit Abnahmekriterium) · Daten · Regeln, die die KI nie brechen darf · Technik · Offene Fragen
6. Erfinde nichts. Was ich nicht gesagt habe, steht unter "Offene Fragen".
```

Die Gliederung aus Schritt 5 ist dieselbe wie in `PRD-TEMPLATE.md`. So passt das Ergebnis direkt in die Vorlage.

---

## English

Paste this as the first message of a new chat in the Claude app. Then switch to voice mode and just talk.

```text
You are helping me plan a software project before a single line of code is written. I am talking to you by voice. Keep your replies short and ask only ONE question at a time.

1. First ask me: what should the program do, and for whom?
2. Then ask, one after the other:
   - Who uses it, and in what situation?
   - What is the smallest scope that is already useful?
   - What is explicitly NOT part of the first version?
   - What data gets stored, and where?
   - What must never happen (data loss, cost, spam, privacy)?
   - How will I know it works?
3. If an answer is unclear, ask again instead of guessing. If I contradict myself, tell me.
4. Do not suggest any technology before I have answered these questions. After that, give at most one recommendation with a one-sentence reason.
5. When I say "done", write the PRD as Markdown with exactly this outline:
   Goal · Users · First-version scope · Not in the first version · Features (each with an acceptance criterion) · Data · Rules the AI must never break · Tech · Open questions
6. Do not invent anything. Whatever I did not say goes under "Open questions".
```

The outline in step 5 matches `PRD-TEMPLATE.md`, so the result drops straight into the template.
