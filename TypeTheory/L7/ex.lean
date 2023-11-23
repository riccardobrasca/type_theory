import TypeTheory.L6.ex

universe u v

open scoped Real

section propext

#check propext

example (P : Prop) (p : P) : P = True := by
  apply propext
  constructor
  · intro _
    trivial
  · intro _
    exact p

example (P : Prop) (np : ¬P) : P = False := by
  apply propext
  constructor
  · intro hP
    exact np hP
  · intro h
    exact False.rec h

example : (∀ (n : N), n + 0 = n) = True := by
  apply propext
  constructor
  · intro _
    trivial
  · intro _
    exact N.add_zero

example : (∀ (n : N), n + 0 = n) = (0 < π) := by
  apply propext
  constructor
  · intro _
    exact Real.pi_pos
  · intro _
    exact N.add_zero

end propext

section quotient

#check Quot

#check Quot.mk

#check Quot.ind

#check Quot.lift

#check Quot.sound

example (A : Sort u) (B : Sort v) (R : A → A → Prop) (f : A → B)
    (H : ∀ a b, R a b → f a = f b) (a : A) :
    Quot.lift f H (Quot.mk R a) = f a := rfl

end quotient

section functional_ext

variable (A : Sort u) (B : Sort v) (a : A)

def R : (A → B) → (A → B) → Prop :=
  fun f g ↦ ∀ a, f a = g a

def X := Quot (R A B)

lemma lift_ok {f g : A → B} (H : (R _ _) f g) (a : A) : f a = g a := by
  apply H

def ev (a : A) : (X (A := A) (B := B)) → B := fun x ↦
  Quot.lift (fun (f : A → B) ↦ f a) (fun _ _ H ↦ lift_ok _ _ H a) x

#check (ev A B a)

def F : (X A B) → (A → B) := fun x a ↦ ev A B a x

lemma comp_rule (f : A → B) : F A B (Quot.mk (R A B) f) = f := rfl

example (f : A → B) : F A B (Quot.mk (R A B) f) = f := by
  rfl

lemma functional_ext (f g : A → B) (H : ∀ a, f a = g a) : f = g := by
  have : R A B f g := H
  have hquot : Quot.mk (R A B) f = Quot.mk (R A B) g := Quot.sound this
  rw [← comp_rule A B f, ← comp_rule A B g, hquot]

#print axioms functional_ext

end functional_ext

namespace foo

axiom quot {α : Sort u} (r : α → α → Prop) : Sort u

axiom quot.mk {α : Sort u} (r : α → α → Prop) (a : α) : quot r

axiom quot.ind {α : Sort u} {r : α → α → Prop} {β : quot r → Prop}
  (mk : ∀ (a : α), β (quot.mk r a)) (q : quot r) : β q

axiom quot.lift {α : Sort u} {r : α → α → Prop} {β : Sort v} (f : α → β)
  (a : ∀ (a b : α), r a b → f a = f b) (a : quot r) : β

axiom quot.sound {α : Sort u} {r : α → α → Prop} {a b : α} (a' : r a b) :
    quot.mk r a = quot.mk r b

axiom quot.rule {A : Sort u} {B : Sort v} (R : A → A → Prop) (f : A → B)
    (H : ∀ a b, R a b → f a = f b) (a : A) :
    quot.lift f H (quot.mk R a) = f a

variable (A : Sort u) (B : Sort v) (a : A)

def R : (A → B) → (A → B) → Prop :=
  fun f g ↦ ∀ a, f a = g a

def X := quot (R A B)

lemma lift_ok {f g : A → B} (H : (R _ _) f g) (a : A) : f a = g a := by
  apply H

noncomputable
def ev (a : A) : (X (A := A) (B := B)) → B := fun x ↦
  quot.lift (fun (f : A → B) ↦ f a) (fun _ _ H ↦ lift_ok _ _ H a) x

#check (ev A B a)

noncomputable
def F : (X A B) → (A → B) := fun x a ↦ ev A B a x

lemma comp_rule (f : A → B) : F A B (quot.mk (R A B) f) = f := by
  unfold F
  unfold ev
  show _ = fun a ↦ f a
  have : ∀ x, quot.lift (fun f => f x) (fun g1 g2 H ↦ lift_ok _ _ H x)
      (quot.mk (R A B) f) = f x := by
    intro x
    apply quot.rule
  sorry

end foo

section set

example (A : Type u) (S T : Set A) : S = T ↔
    ∀ a, a ∈ S ↔ a ∈ T := by
  constructor
  · intro h
    simp [h]
  · intro h
    apply funext
    intro a
    apply propext
    exact h a

end set

section choice

example (A : Sort u) : Nonempty A ↔ ∃ (_ : A), True := by
  constructor
  · rintro ⟨a⟩
    use a
  · rintro ⟨a, _⟩
    exact ⟨a⟩

#check Classical.choice

example (P : Prop) : P = True ∨ P = False := by
  cases em P with
  | inl h =>
    left
    apply propext
    constructor
    · intro _
      trivial
    · intro _
      exact h
  | inr h =>
    right
    apply propext
    constructor
    · exact h
    · intro H
      exact False.rec H

example (P : Prop) : ¬¬P → P := by
  intro H
  cases em P with
  | inl h =>
    exact h
  | inr h =>
    exfalso
    exact H h

example (P Q : Prop) (h : P → Q) (h' : ¬P → Q) : Q := by
  cases em P with
  | inl hP =>
    exact h hP
  | inr hnP =>
    exact h' hnP

example (P Q : Prop) (h : P → Q) (h' : ¬P → Q) : Q := by
  by_cases hP : P
  · exact h hP
  · exact h' hP

example : ∀ (P : Prop), P ∨ ¬P := by
  by_contra' h
  obtain ⟨P, hP⟩ := h
  exact hP.1 hP.2

end choice
