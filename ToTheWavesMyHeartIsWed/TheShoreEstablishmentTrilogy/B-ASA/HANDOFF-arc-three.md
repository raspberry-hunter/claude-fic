---
title: Handoff — end of arc two, setup for arc three
series: The Shore Establishment / A Standing Arrangement
status: claude-draft
placement: written 1959-in-story; drafted at the close of A Standing Arrangement
summary: State of the sequence, conventions, canon rulings, character positions and live threads at the end of arc two.
---

# Handoff

Everything a fresh session needs to pick this up without re-deriving it. Read the calibration sheets and the two Continuity files as well; this covers what those don't.

---

## 1. Where the sequence stands

| | Arc | Acronym | Installments | Span |
|---|---|---|---|---|
| Source | *To the Waves My Heart Is Wed* | — | 9 chapters | May 1954 |
| Arc one | **The Shore Establishment** | TSE | 01–09, plus 10 *The Interim* as coda | May 1954 – June 1955 |
| Arc two | **A Standing Arrangement** | ASA | 01–12 | June 1955 – October 1959 |
| Arc three | **Not Fewer Than Two** (proposed) | NFT | — | 1960 onward |

Arc two closes on Aguilar saying *She's slower this year* and Pascual answering *Yes. I know.*

**Arc three title.** From clause eleven: *The Institute shall maintain in its care not fewer than two living specimens of Nereopithecus aestuarius at all times, save where no specimen is obtainable.* The clause is the obligation that will send an order to Port of Spain the morning after Gamma dies. The second half — *save where no specimen is obtainable* — is the sentence Jean's eleven years exist to make untrue.

---

## 2. Conventions

**Filenames:** `NN-ACRONYM_Title_With_Underscores.md`, numbered continuously within an arc from 01.

**Frontmatter:**
```
title / series / follows / order / status / placement / summary
```
`status`: `my-draft` (C wrote it) · `claude-draft` (Claude wrote it) · `collaboration-draft` (both). Flag any markdown file arriving without a status.
`placement`: dates, locations, POV character(s).
Em dashes (—), not `--`, in `claude-draft` and `collaboration-draft` files.

**Deliverables:** word count with every file. No summary of the fiction in chat — only what isn't on the page. Invented elements get flagged for ratification with an explicit veto invitation.

---

## 3. Contraction calibration — the most-missed rule

Targets in dialogue: **Reggie 5.3 / 100 words, Pascual 5.9.** Arc one drifted badly (7.15 in TSE-01 down to 0.65 in TSE-10); check every installment before delivering.

**Narration:** contracts in every POV **except Reggie's.** Reggie-POV narration stays uncontracted. Reported Reggie inside another POV's narration keeps his uncontracted register. This was missed repeatedly in arc two — Hester-POV, Pascual-POV and Spilsbury-POV narration all came in at 0.3–1.0 on first pass and had to be raised.

**Spikes.** One designated uncontracted passage per installment, at maximum pressure, driven to ~0.0 while the surrounding text sits at 6–7 so the drop reads. Reggie's tell is dropping contractions under pressure or when itemising. Pascual's is a rehearsed or deliberately exact speech. Established spikes: 01 Reggie's refusal-of-an-answer; 05 Pascual's rehearsed accusation; 07 Reggie's refusal to Spilsbury; 10 Pascual's knife; 11 Reggie's confession (and the *promise* immediately after contracts, so the register shift carries description → vow); 12 Pascual's confession.

**Hester and Spilsbury** are their own cases. Hester's dialogue sits at ~0.0 permanently — she does not contract, ever, and that is characterising. Spilsbury contracts heavily and fast.

**Measurement.** A naive regex on `"([^"]+)"` pairs the closing quote of one paragraph with the opening quote of the next and counts narration as dialogue. Extract lines beginning with `"` instead. `calib.py` in the working directory does this.

---

## 4. Canon rulings settled during arc two

**The vow.** Mutual hand-to-face is the mate bond; the circuit shuts with an audible click. One hand with no hand back is the parental form a calf makes to its mother, and is not the vow. A mermaid makes the mate vow once while it stands; he can make another only after the first has gone. Chumley made his to Gamma in the winter of 1955 — retconned from a one-sided reading, at C's instruction.

**Thinning vs breaking.** Distance thins a bond, by degrees, over weeks — which is how Hester knows Tom was carried alive out of the Essequibo. Death breaks it instantly, with no warning and no getting used to it on the way down. What does not thin, in either case, is the silence.

**The signal.** Nothing reaches a sensitive person on dry land. A hand in the water carries a hum — comforting from a contented animal, an onslaught from a distressed one. Face or body in the water is overwhelming. Hester's barrier was never a thirty-foot signal; it was social, plus one attempt with Alpha on 7 August 1949 that put her on the concrete.

**Signal strength goes with the animal's state.** Charles got a great deal off a solitary male five months into a decline; Aguilar gets a hose fitting off a fat mated calf. Nobody in the field knows there is a loud end, because the published husbandry says keep them in pairs.

**The vow is public.** It sits in Andersen and Wilde in plain words. One working naturalist in forty years has taken it seriously: Spilsbury, who read the passage aloud out of Charles's crate on 22 May 1954 and has never mentioned it since.

---

## 5. Reggie — stop adding pathologies

Canon gives him **one** flaw: he cannot take anything by halves. Everything else follows from it. During arc two I accreted three more; two were removed and the third stands only because arc one established it.

- **Kept, canon:** he does not take things by halves — not as an incapacity but as a tendency he does not check until the consequences get beyond him. He *can* stop. He generally doesn't in time. That is the difference between a defect and a fate, and the whole sequence turns on it.
- **To be removed from ASA:** "cannot originate a request." This was drift, not canon; he asks for things perfectly well throughout the source and arc one. ASA-04 (*Nothing Asked*) is built on it and will need reworking — the nine drafts still work as a man unable to write **this** letter to **this** man, which is a fact about Spilsbury and 1946, not a standing incapacity. Also referenced in ASA-05 ("the nine letters in the drawer") and ASA-11 (the burnt folder), both of which survive under the narrower reading.
- **Recast (was "no working model of being picked"):** because he doesn't do things by halves, it doesn't arrive that anyone could doubt him. Not modesty, not insecurity — a failure of imagination about somebody else, produced by his own intensity. *From in here it isn't a question that can be asked.* Fixed in ASA-05, 06, 07.
- **Deleted:** "cannot audit his own column." Removed from ASA-10 entirely. What Pascual sits with is not a diagnosis of Reggie but his own act.

**And as of ASA-11 the flaw has changed category.** Reggie told Pascual for five years that his constancy was a physical property, like the tide. On 7 December 1958 he found out he has carried a torch for Spilsbury since November 1946 and drank ninety seconds of warmth like a man who hadn't had a drink in a decade. So it is not a property; it is something he *does*, and therefore something he can choose against. What he offers now is a promise, not a description: he will choose, and say so on the days it is hard, on the day.

---

## 6. Where everyone is, October 1959

**Reggie Tar, 40** (b. Dec 1918; 35/36 in 1954, 27 in the 1946 corridor — authorial fiat, C). Director since 29 Feb 1956. Has said yes to the standing body for 1961–62, on Hester's nine pages, and will be asked again. Said *te quiero* for the first time on about 2 February 1959, in a doorway, at twenty to twelve, having practised it for three and a half years in the boat. Cannot hear *I am finished* without something going over in his chest and expects about four more years of it.

**Pascual Pobil, 46.** Medical officer; practice on the main island; back across the water three days a week since January 1959. Named in the acknowledgements of the contact paper for pp. 31–32. Has told Reggie that on 30 November 1958 he chose, in two seconds, to pick up the one irreplaceable thing in the room and hit him with it.

**Them.** North-side house since 9 November 1955. Boat called *Doris*, which will not be renamed, because it is unlucky. Separate rooms 4 December 1958 – 2 March 1959; the fisheries boxes went back to the office on 17 July 1959 and the second bedroom has not been mentioned since. The arguing came back on 14 March 1959, over the paraffin, twenty-five minutes, Pascual winning on a technicality about the account book.

**Hester Bevan, 63.** Running the Institute in all but name since February 1958. Bonded to Tom on the Essequibo 1916, taken by four men with a net and a tarpaulin on 9 December 1917. Has told four people in forty-one years. Has Charles's notebook and a thirty-year publication intention. Has put a hand in Gamma's pen eleven times since April 1958 and nobody discusses it.

**Colonel Bevan, 73.** Coronary thrombosis 4 February 1958. Survived; reads the drains file from a chair. Pobil's prognosis: *It may be eleven years. It may be March.*

**Nestor Aguilar, 45.** On the establishment for life, salary raised every April on Hester's instruction so that nobody can offer him anything he'd want more. Sensitive; **not** bonded — Chumley is mated to Gamma. Named author.

**John Clarke, 28.** Numbering adopted as ministry standard. Card printed at his own expense in Bridgetown. Answered the Woods Hole letter himself in July 1956, two years late, on his own terms.

**Jean Leslie, 34.** Florida since February 1956. Eleven-year survey of the Ten Thousand Islands, funded in perpetuity by the tenth page. 104 of 1,100 miles surveyed. One photograph, numbered and dated, of some mud. One torn net, four feet across, that did not look like a propeller.

**Alec Spilsbury, 53.** Unredeemed, undefeated, and no longer a question. Has two cards he cannot account for: the Nicholson fact, and *AGUILAR — dep. var.?* Has a third he filed blank in December 1958: *R.T. — block, 4 nights —*.

**Gamma**, not less than eight, 51 months paired, oldest ever recorded, slower this year. **Chumley**, six, bigger than she is, still brings her things.

**Charles Cholmondeley** may not be dead. Rather better than even and not one degree more. Nobody has looked, because an enquiry is a record, and the not-looking is the protection.

---

## 7. Live threads for arc three

1. **Gamma.** The climax. Chumley's bond breaks the instant she stops — no thinning, no warning. What is then in that pen is a solitary adult male in the silence, i.e. Beta.
2. **Nestor,** standing four feet away, sensitive, fond of him, and perfectly free to put his hand on the side of that animal's face.
3. **Clause eleven.** The morning after Gamma dies it obliges the Martin to buy a mermaid. One in three survives the passage. *Save where no specimen is obtainable* is the only door.
4. **Jean,** who is the only exit from Hester's sum, and has eleven years.
5. **Lisbon.** September 1959: a courteous four-paragraph letter asking whether pp. 31–32 preclude *graduated rather than complete separation.* The confound paragraph worked and the man found the crack anyway. Reggie is answering it at length, read aloud to Pascual before it goes.
6. **Rome.** Reggie leaving the island for an inspectorate with the power to license holdings — which is also the power to refuse one to a man who isolates an animal.
7. **The Colonel,** and Hester after him.
8. **Hester's notebook,** and whether page 206 is ever published.
9. **Charles.**

---

## 8. Errors caught in arc two — do not repeat

- The 1946 corridor: Spilsbury stopped it, three seconds, *No, I don't think so*, then *bring the plate through*. Reggie has always known that. What he never knew was what the man understood by it. **`PATCH-06-TSE_Negative_Result.md` is still outstanding** — arc one has not been amended.
- Charles was on a postgraduate's allowance, not unpaid; and he had packed a knapsack days before. Reggie did not get him away; he made a departure that was happening anyway survivable.
- Beta was five months into a decline, nine months alone.
- The pen edge is eight feet from the rail with a step cut in above the waterline. Nothing is thirty feet above anything.
- Spilsbury never needed Charles's notebook: the arrested-decline table is on page nineteen of *Tar, Leslie and Pobil 1954*, in a journal with his own subscription label on it.
- POV discipline: do not narrate a scene the POV character was not in. ASA-10 originally showed Spilsbury reading the four paragraphs, in an installment narrated close on Pascual four miles away and not speaking to anybody.
- Dates: verify against the day of the week. 8 December 1958 was a Monday, which is what fixed the ASA-09/10 timeline.
