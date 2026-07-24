<!-- # Arthum AI — AI Tutor Chatbot UX Spec (Design Only)

> Scope: Screen UX/interaction design for the Educational Chatbot to feel like a premium personal AI teacher. No code changes.

---

## 1) Product experience goals
- Replace “ChatGPT-like chat” with a **teaching** experience.
- Keep students oriented: **what we’re learning now** + **what to do next**.
- Responses must be **chunked** into lesson sections (avoid long paragraphs).
- Maintain your app’s **glassmorphism** aesthetic while adding a futuristic premium feel.

---

## 2) Complete chatbot screen layout (portrait)

### 2.1 Overall structure
- **Scaffold + SafeArea**
- **MyAIBackground** (existing) behind everything.

### 2.2 Top app bar (compact)
- Left: Back (or drawer/menu)
- Center: Title: **“AI Tutor”** (or “Arthum AI Tutor”)
- Right: Icons
  - “Focus mode” (reduce distractions)
  - Optional: “Help” / “Accessibility”

### 2.3 Tutor header row (learning context)
Placed directly under AppBar.
- Glass card container (blur + border glow)
- Contains:
  - **Tutor Avatar** (animated, persistent)
  - **Tutor state label** (single line):
    - “Explaining”, “Thinking…”, “Great job!”, “Let’s try simpler”
  - **Current learning objective** (topic short-form): e.g., “Photosynthesis • Grade 9”
  - Optional micro progress bar (very subtle): e.g., 1/3 steps

### 2.4 Main content area (chat + lessons)
- Scrollable list (ListView)
- Tutor avatar stays **visible** via a Stack overlay and/or fixed header region.

Message list items:
- **User messages**: right aligned compact bubble
- **Tutor messages**: left aligned “lesson cards”
  - Each tutor message card is structured with:
    - Lesson header / topic line
    - Section blocks (Definition, Key Points, Example, Quiz prompt…)
    - A quick actions row (contextual)

### 2.5 Bottom input bar (persistent)
- Text field placeholder:
  - “Ask your tutor… (e.g., ‘Explain photosynthesis simply’)”
- Send button (glass gradient)
- Optional mic icon if your product supports it.

### 2.6 Typing / thinking indicator
- Replace generic “typing dot row” with:
  - avatar state = **Thinking**
  - subtle inline label under header: “Tutor is forming the lesson…”

---

## 3) Widget hierarchy (conceptual)
- `ChatbotTutorScreen`
  - `AppBar`
  - `TutorHeader`
    - `TutorAvatar` (Rive/Lottie)
    - `TutorStateText`
    - `LearningObjectiveText`
  - `Expanded`
    - `Stack`
      - `ChatList`
        - `MessageItem`
          - `UserBubble`
          - `TutorLessonCard`
            - `TutorLessonHeader`
            - `TutorSectionList`
              - `DefinitionSection`
              - `ImportantPointsSection` (chips + expand)
              - `WorkedExamplesSection` (step tiles)
              - `RevisionNotesSection` (short bullets)
              - `RelatedTopicsSection` (topic chips)
            - `TutorQuickActionsRow`
              - Explain Again
              - Give Example
              - Quiz Me
              - Important Points (secondary/expand)
      - `TypingIndicatorOverlay` (optional)
  - `MessageInputBar`

---

## 4) User interaction flow (premium “teacher”)

### 4.1 Default teaching loop
1. User asks a question.
2. Tutor enters **Thinking** state.
3. Tutor returns a **lesson card**:
   - Short definition first
   - Key points as chips/bullets
   - Examples/steps next
4. Tutor offers next actions:
   - Explain Again (simpler)
   - Give Example (more)
   - Quiz Me (convert lesson into questions)
   - Important Points (expand/collapse)

### 4.2 Quiz flow
- When the user taps **Quiz Me**:
  - Tutor shows a mini-quiz inside the lesson card.
  - After answer tap:
    - Tutor state → **Happy** (correct) or **Encouraging** (not yet)
    - Tutor provides a brief “why” + one next step.

### 4.3 Handling errors / connectivity
- If backend fails:
  - Show a short tutor card message:
    - “I’m having trouble connecting. Want a simpler explanation or try again?”
  - Keep input usable.

---

## 5) Avatar behavior flow (states)

### 5.1 Avatar states
- **Idle**: breathing glow + occasional blink
- **Thinking**: gentle rotation / eyes scanning + shimmer around avatar
- **Explaining**: “speaking” motion + warmer glow to indicate teaching
- **Happy**: subtle sparkle burst (very small, non-distracting)
- **Encouraging**: soft supportive pulse + microcopy hint

### 5.2 State transitions
- typing boolean true → **Thinking**
- bot message starts rendering → **Explaining**
- quiz correct → **Happy**
- quiz incorrect / user needs guidance → **Encouraging**
- after lesson fully displayed → return to **Idle** after a short pause

---

## 6) Chat message appearance (premium + educational)

### 6.1 User messages
- Right-aligned glass/gradient bubble
- Max width to preserve readability (avoid full-width)
- Typography smaller than tutor cards for hierarchy

### 6.2 Tutor messages (lesson cards)
- Left-aligned glass cards with:
  - border glow
  - section dividers
- Each section:
  - has a clear title
  - uses chips, steps, or short blocks
- Truncation strategy:
  - default: show 1–3 bullets
  - expand on tap for “Important Points” / longer sections

### 6.3 Progressive disclosure
- Prevent overload by revealing sections progressively:
  - Definition immediately
  - Key points + example shortly after (stagger)

---

## 7) Placement & layout recommendations for avatar
- Position: **Top-left in a fixed/overlay header region** (teaching persona)
- Rationale:
  - keeps it always visible
  - reinforces “teacher beside the learner” feeling
- Size guidance:
  - 64–96dp depending on screen size
- Keep it clear of the message list scroll to avoid accidental occlusion.

---

## 8) Quick action buttons design

### 8.1 Where displayed
- Inside each tutor lesson card under the content.
- Only show under the **latest tutor message** (unless quiz card is open).

### 8.2 Visual style
- Buttons as compact glass pills:
  - Primary: Explain Again, Quiz Me
  - Secondary: Give Example
  - Tertiary link/pill: Important Points
- Include icons + short labels (2–3 words max).

### 8.3 Behavior
- Explain Again:
  - triggers “rephrase simpler” guided prompt
- Give Example:
  - triggers additional worked example(s)
- Quiz Me:
  - transforms lesson into a mini-quiz UI
- Important Points:
  - toggles expand/collapse within same lesson card

---

## 9) Animations (alive but not distracting)

### 9.1 Motion principles
- Motion should clarify state changes (thinking/explaining/feedback)
- Respect motion sensitivity (reduced motion mode)

### 9.2 Recommended animations
- Tutor lesson card entry:
  - fade + slide (150–220ms)
- Section items:
  - stagger appearance (60–90ms)
- Avatar:
  - looped micro animations per state
  - short sparkle burst for Happy (max ~0.7–1.2s)
- Button feedback:
  - scale to 0.98 + glow ring for pressed state

---

## 10) Accessibility & readability requirements
- Minimum tap target: 44dp
- Minimum font sizes:
  - body 14–16sp
  - section titles 14–16sp bold
- Contrast:
  - ensure text remains readable over glass blur
- Reduce cognitive load:
  - avoid >3 sections visible at once without user interaction
- Dynamic text scaling:
  - ensure cards reflow and do not clip
- Reduced motion:
  - disable stagger + keep avatar to minimal idle glow
- Screen reader labels:
  - “AI Tutor: Explaining” for tutor state changes

---

## 11) Color recommendations (glassmorphism + futuristic)

### 11.1 Base palette
- Background (dark):
  - `#060A14` to `#0A1022`
- Primary tutor accent (teal/cyan):
  - `#2AF6D6`
- Secondary futuristic accent (violet):
  - `#8A5CFF`
- Text:
  - Primary: `#F5F7FF`
  - Secondary: `rgba(245, 247, 255, 0.75)`

### 11.2 Glass styling
- Card border glow:
  - `rgba(42, 246, 214, 0.25)`
  - `rgba(138, 92, 255, 0.18)`
- User bubble tint (less intense than tutor):
  - `rgba(138, 92, 255, 0.18)`

### 11.3 Avatar glow by state
- Idle/Explaining: teal glow
- Thinking: amber-ish glow (`#FFC857`) or cool cyan emphasis
- Happy: green (`#41F28A`)
- Encouraging: blue (`#4DA3FF`)

---

## 12) Recommended animation technology

### Preferred: Rive
- Strong for **state machines** (perfect for Idle/Thinking/Explaining/Happy/Encouraging)
- Efficient and smooth transitions driven by widget/controller state
- Single asset can contain all avatar states

### Alternative: Lottie
- Works well for fixed animations
- Multiple files per emotion/state may be required
- State transitions require more glue logic

---

## 13) Roadmap to implement in Flutter (high-level)
1. Finalize tutor content model mapping:
   - backend fields → UI sections
2. Integrate avatar:
   - Add TutorAvatar widget (Rive) with state machine inputs
3. Replace chat bubbles with lesson cards:
   - TutorLessonCard + section components
4. Implement structured rendering:
   - Definition card, Key points chips, Example step tiles
5. Add contextual buttons row:
   - Wire button actions to guided prompts later
6. Upgrade thinking experience:
   - Avatar state Thinking + compact helper text
7. Accessibility pass:
   - contrast, tap targets, dynamic type, reduced motion
8. Performance pass:
   - lazy building, minimize animation load

---

## 14) Acceptance criteria (UX)
- Tutor avatar always visible and changes state meaningfully.
- Tutor responses are chunked into sections.
- Buttons are clear, limited, and always help learning.
- No long paragraphs; max 2–3 short blocks visible without interaction.
- Premium visual style consistent with glassmorphism.
 -->
