# Motion Specialist Routing

Motion is a recommended conditional specialist, not a universal runtime dependency.

The preferred specialist is the official Motion AI Kit `/motion` skill from:

https://github.com/motiondivision/ai-kit

Official install/update command:

```powershell
npx motion-ai@latest
```

The installer is owned by Motion and may configure both the `/motion` skill and Motion's hosted MCP integration. This repository does not vendor, pin, or rewrite that external skill.

## Invoke Motion when

The task creates or materially changes:

- animation or transition behavior;
- enter/exit presence animation;
- layout animation or shared-layout transitions;
- drag, swipe, reorder, or gesture interaction;
- spring-based motion;
- scroll-triggered or scroll-linked motion;
- animation sequencing/staggering;
- animation performance behavior;
- motion accessibility or reduced-motion behavior.

Do not invoke the specialist mechanically for every CSS change.

## CSS first

Prefer native CSS when it fully solves the task without unnecessary runtime complexity.

Typical CSS-first cases:

- hover/focus/press color or opacity transitions;
- simple fade/slide where lifecycle coordination is unnecessary;
- spinners and shimmer/loading effects;
- basic keyframe effects;
- simple state transitions that do not require gesture physics, presence coordination, shared layout, or interruption-aware springs.

Using the Motion specialist does not mean the project must install the Motion runtime. The specialist may recommend CSS.

## Runtime dependency rule

Do not add or upgrade the `motion` package merely because the specialist is available.

Before adding a runtime dependency:

1. inspect the project's existing animation stack;
2. preserve the project's framework and library choices;
3. prefer the installed version when Motion is already present;
4. add Motion only when its capabilities materially simplify or improve the requested behavior;
5. do not replace another established animation library without explicit approval.

For React projects that already use Motion, follow the current project version and its supported import/API conventions rather than assuming an API from model memory.

## Project authority

Project design rules remain authoritative over the Motion specialist.

The specialist may improve implementation quality, timing, physics, accessibility, and performance. It must not invent a new visual language or add decorative motion that the task did not call for.

## Verification contract

For material motion changes, verify all applicable states:

1. **initial state** — before the interaction or animation starts;
2. **active/transient state** — while the animation or gesture is in progress when observable;
3. **settled state** — after animation completion;
4. **repeat/interruption state** — repeated, reversed, cancelled, or rapidly retriggered interaction when relevant;
5. **reduced-motion state** — with `prefers-reduced-motion` enabled when the effect is nontrivial.

Check that:

- final geometry is correct after animation settles;
- animation does not introduce clipping, overflow, layout jumps, stale transforms, or inaccessible off-screen controls;
- interaction remains usable with reduced motion;
- reduced motion preserves meaning and task completion rather than merely disabling required feedback;
- gesture-only behavior has an appropriate non-gesture interaction path when accessibility or product requirements call for it;
- repeated or interrupted animations do not leave stale state;
- scroll-linked effects remain correct at representative scroll positions and responsive widths;
- no new relevant browser-console errors appear.

A layout-affecting motion change is Class A unless there is strong evidence that it cannot affect geometry or responsive behavior.

A color/opacity-only transition with no plausible geometry effect may remain Class B.

## Performance

For substantial animation work, especially many simultaneous elements, scroll-linked effects, large transforms, filters, or layout animation, use available performance tooling when warranted.

If MotionScore is available through the installed Motion AI Kit, it may be used as supporting evidence. It does not replace browser verification or rendered visual QA.

## Missing specialist

If `/motion` is unavailable:

- do not silently claim the Motion specialist phase ran;
- apply the CSS-first and accessibility rules in this reference directly;
- use current project/library documentation when API correctness matters;
- report reduced specialist coverage only when motion was material to the task.
