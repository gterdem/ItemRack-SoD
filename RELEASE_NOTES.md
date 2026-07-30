# ItemRack - Season of Discovery - Release v1.1.3

A bugfix for resizing the on-screen slot buttons.

---

### 🔧 Fixed
* **Resizing moved slot buttons no longer throws a Lua error.** If you had dragged your on-screen slot buttons somewhere, using the **Scale** slider could spam `Action[SetPoint] failed because[SetPoint would result in anchor family connection]` — and only the first button actually resized, because the error stopped the resize before it reached the others. A dragged button is left anchored to the screen by the client, and the rescale added a UIParent anchor on top of that, which the client has refused since patch 9.0. Its anchors are now cleared before it is repositioned, so **every** button resizes and stays exactly where you put it.

_Affects anyone who has moved their slot buttons away from the default position; no settings change needed._
