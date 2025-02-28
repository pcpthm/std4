/-
Copyright (c) 2016 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura, Jeremy Avigad, Mario Carneiro
-/
import Std.Logic
import Std.Tactic.Basic
import Std.Data.Nat.Basic

namespace Nat

theorem succ_ne_self : ∀ n : Nat, succ n ≠ n
| 0,   h => absurd h (succ_ne_zero 0)
| n+1, h => succ_ne_self n (Nat.noConfusion h id)

protected theorem eq_zero_of_add_eq_zero_right : ∀ {n m : Nat}, n + m = 0 → n = 0
| 0,   m => by simp [Nat.zero_add]
| n+1, m => fun h => by
  rw [add_one, succ_add] at h
  cases succ_ne_zero _ h

protected theorem eq_zero_of_add_eq_zero_left {n m : Nat} (h : n + m = 0) : m = 0 :=
  @Nat.eq_zero_of_add_eq_zero_right m n (Nat.add_comm n m ▸ h)

attribute [simp] Nat.pred_zero Nat.pred_succ

/- properties of inequality -/

theorem ne_of_gt {a b : Nat} (h : b < a) : a ≠ b := (ne_of_lt h).symm

protected theorem le_of_not_le {a b : Nat} : ¬ a ≤ b → b ≤ a := (Nat.le_total a b).resolve_left

protected theorem pos_of_ne_zero {n : Nat} : n ≠ 0 → 0 < n := (eq_zero_or_pos n).resolve_left

protected theorem pos_iff_ne_zero {n : Nat} : 0 < n ↔ n ≠ 0 := ⟨ne_of_gt, Nat.pos_of_ne_zero⟩

protected theorem lt_iff_le_not_le {m n : Nat} : m < n ↔ m ≤ n ∧ ¬ n ≤ m :=
  ⟨fun h => ⟨Nat.le_of_lt h, Nat.not_le_of_gt h⟩, fun h => Nat.gt_of_not_le h.2⟩

@[simp] protected theorem not_le {a b : Nat} : ¬ a ≤ b ↔ b < a :=
  ⟨Nat.gt_of_not_le, Nat.not_le_of_gt⟩

@[simp] protected theorem not_lt {a b : Nat} : ¬ a < b ↔ b ≤ a :=
  ⟨Nat.ge_of_not_lt, flip Nat.not_le_of_gt⟩

theorem pred_lt_pred : ∀ {n m : Nat}, n ≠ 0 → n < m → pred n < pred m
| 0,   _,   h, _ => (h rfl).elim
| _+1, _+1, _, h => lt_of_succ_lt_succ h

theorem succ_le_succ_iff {a b : Nat} : succ a ≤ succ b ↔ a ≤ b :=
  ⟨le_of_succ_le_succ, succ_le_succ⟩

protected theorem add_left_cancel_iff {n m k : Nat} : n + m = n + k ↔ m = k :=
  ⟨Nat.add_left_cancel, fun | rfl => rfl⟩

protected theorem add_le_add_iff_le_right (k n m : Nat) : n + k ≤ m + k ↔ n ≤ m :=
⟨Nat.le_of_add_le_add_right, fun h => Nat.add_le_add_right h _⟩

protected theorem lt_of_add_lt_add_left {k n m : Nat} (h : k + n < k + m) : n < m :=
  Nat.lt_of_le_of_ne (Nat.le_of_add_le_add_left (Nat.le_of_lt h)) fun heq =>
    Nat.lt_irrefl (k + m) <| by rwa [heq] at h

protected theorem lt_of_add_lt_add_right {a b c : Nat} (h : a + b < c + b) : a < c :=
  Nat.lt_of_add_lt_add_left ((by rwa [Nat.add_comm b a, Nat.add_comm b c]): b + a < b + c)

protected theorem lt_add_right (a b c : Nat) (h : a < b) : a < b + c :=
  Nat.lt_of_lt_of_le h (Nat.le_add_right _ _)

protected theorem lt_add_of_pos_right {n k : Nat} (h : 0 < k) : n < n + k :=
  Nat.add_lt_add_left h n

protected theorem lt_add_of_pos_left {n k : Nat} (h : 0 < k) : n < k + n := by
  rw [Nat.add_comm]; exact Nat.lt_add_of_pos_right h

/- sub properties -/

attribute [simp] Nat.zero_sub

theorem sub_lt_succ (a b : Nat) : a - b < succ a :=
  lt_succ_of_le (sub_le a b)

protected theorem sub_le_sub_right {n m : Nat} (h : n ≤ m) : ∀ k, n - k ≤ m - k
  | 0   => h
  | z+1 => pred_le_pred (Nat.sub_le_sub_right h z)

-- port note: bit0/bit1 items have been omitted.

protected theorem add_self_ne_one : ∀ (n : Nat), n + n ≠ 1
  | n+1, h =>
    have h1 : succ (succ (n + n)) = 1 := succ_add n n ▸ h
    Nat.noConfusion h1 fun.

/- subtraction -/

protected theorem le_of_le_of_sub_le_sub_right :
    ∀ {n m k : Nat}, k ≤ m → n - k ≤ m - k → n ≤ m
  | 0, m, _, _, _ => m.zero_le
  | succ _, _, 0, _, h₁ => h₁
  | succ _, 0, succ k, h₀, _ => nomatch not_succ_le_zero k h₀
  | succ n, succ m, succ k, h₀, h₁ => by
    simp [succ_sub_succ] at h₁
    exact succ_le_succ <| Nat.le_of_le_of_sub_le_sub_right (le_of_succ_le_succ h₀) h₁

protected theorem sub_le_sub_right_iff {n m k : Nat} (h : k ≤ m) : n - k ≤ m - k ↔ n ≤ m :=
  ⟨Nat.le_of_le_of_sub_le_sub_right h, fun h => Nat.sub_le_sub_right h k⟩

protected theorem add_le_to_le_sub (x : Nat) {y k : Nat} (h : k ≤ y) :
    x + k ≤ y ↔ x ≤ y - k := by
  rw [← Nat.add_sub_cancel x k, Nat.sub_le_sub_right_iff h, Nat.add_sub_cancel]

protected theorem sub_lt_of_pos_le (a b : Nat) (h₀ : 0 < a) (h₁ : a ≤ b) : b - a < b :=
  Nat.sub_lt (Nat.lt_of_lt_of_le h₀ h₁) h₀

protected theorem sub_one (n : Nat) : n - 1 = pred n := rfl

theorem succ_sub_one (n : Nat) : succ n - 1 = n := rfl

theorem succ_pred_eq_of_pos : ∀ {n : Nat}, 0 < n → succ (pred n) = n
  | succ _, _ => rfl

protected theorem le_of_sub_eq_zero : ∀ {n m : Nat}, n - m = 0 → n ≤ m
  | n, 0, H => by rw [Nat.sub_zero] at H; simp [H]
  | 0, m+1, _ => Nat.zero_le (m + 1)
  | n+1, m+1, H => Nat.add_le_add_right
    (Nat.le_of_sub_eq_zero (by simp [Nat.add_sub_add_right] at H; exact H)) _

protected theorem eq_zero_of_nonpos : ∀ (n : Nat), ¬0 < n → n = 0
  | 0 => fun _ => rfl
  | n+1 => fun h => absurd (Nat.zero_lt_succ n) h

protected theorem sub_eq_zero_iff_le : n - m = 0 ↔ n ≤ m :=
  ⟨Nat.le_of_sub_eq_zero, Nat.sub_eq_zero_of_le⟩

protected theorem sub_eq_iff_eq_add {a b c : Nat} (ab : b ≤ a) : a - b = c ↔ a = c + b :=
  ⟨fun c_eq => by rw [c_eq.symm, Nat.sub_add_cancel ab],
   fun a_eq => by rw [a_eq, Nat.add_sub_cancel]⟩

protected theorem lt_of_sub_eq_succ (H : m - n = succ l) : n < m :=
  Nat.not_le.1 fun H' => by simp [Nat.sub_eq_zero_of_le H'] at H

@[simp] protected theorem min_eq_min (a : Nat) : Nat.min a b = min a b := rfl

@[simp] protected theorem max_eq_max (a : Nat) : Nat.max a b = max a b := by
  simp only [Nat.max, max, ← Nat.not_le]; split <;> rfl

protected theorem min_comm (a b : Nat) : min a b = min b a := by
  simp [min]
  by_cases h₁ : a ≤ b <;> by_cases h₂ : b ≤ a <;> simp [h₁, h₂]
  · exact Nat.le_antisymm h₁ h₂
  · cases not_or_intro h₁ h₂ <| Nat.le_total ..

protected theorem min_le_left (a b : Nat) : min a b ≤ a := by
  simp [min]; by_cases h : a ≤ b <;> simp [h]
  exact Nat.le_of_not_le h

protected theorem min_eq_left {a b : Nat} (h : a ≤ b) : min a b = a := by simp [min, h]

protected theorem min_eq_right {a b : Nat} (h : b ≤ a) : min a b = b := by
  rw [Nat.min_comm a b]; exact Nat.min_eq_left h

protected theorem zero_min (a : Nat) : min 0 a = 0 := Nat.min_eq_left (zero_le a)

protected theorem min_zero (a : Nat) : min a 0 = 0 := Nat.min_eq_right (zero_le a)

protected theorem max_comm (a b : Nat) : max a b = max b a := by
  simp only [← Nat.max_eq_max, Nat.max]
  by_cases h₁ : a ≤ b <;> by_cases h₂ : b ≤ a <;> simp [h₁, h₂]
  · exact Nat.le_antisymm h₂ h₁
  · cases not_or_intro h₁ h₂ <| Nat.le_total ..

protected theorem max_eq_right {a b : Nat} (h : a ≤ b) : max a b = b := by
  simp [max, h, Nat.not_lt.2 h]

protected theorem max_eq_left {a b : Nat} (h : b ≤ a) : max a b = a := by
  rw [← Nat.max_comm b a]; exact Nat.max_eq_right h

-- Distribute succ over min
theorem min_succ_succ (x y : Nat) : min (succ x) (succ y) = succ (min x y) := by
  simp [min, succ_le_succ_iff]; split <;> rfl

theorem sub_eq_sub_min (n m : Nat) : n - m = n - min n m := by
  rw [min]; split
  · rw [Nat.sub_eq_zero_of_le ‹n ≤ m›, Nat.sub_self]
  · rfl

@[simp] protected theorem sub_add_min_cancel (n m : Nat) : n - m + min n m = n := by
  rw [sub_eq_sub_min, Nat.sub_add_cancel (Nat.min_le_left n m)]

/- multiplication -/

protected theorem mul_right_comm (n m k : Nat) : n * m * k = n * k * m := by
  rw [Nat.mul_assoc, Nat.mul_comm m, ← Nat.mul_assoc]

/- mod -/

-- TODO mod_core_congr, mod_def

theorem mod_two_eq_zero_or_one (n : Nat) : n % 2 = 0 ∨ n % 2 = 1 :=
  match n % 2, @Nat.mod_lt n 2 (by simp) with
  | 0,   _ => Or.inl rfl
  | 1,   _ => Or.inr rfl
  | k+2, h => absurd h (λ h => not_lt_zero k (lt_of_succ_lt_succ (lt_of_succ_lt_succ h)))

/- div & mod -/

-- TODO div_core_congr, div_def

theorem mod_add_div (m k : Nat) : m % k + k * (m / k) = m := by
  induction m, k using mod.inductionOn with rw [div_eq, mod_eq]
  | base x y h => simp [h]
  | ind x y h IH => simp [h]; rw [Nat.mul_succ, ← Nat.add_assoc, IH, Nat.sub_add_cancel h.2]

/- div -/

@[simp] protected theorem div_one (n : Nat) : n / 1 = n := by
  have := mod_add_div n 1
  rwa [mod_one, Nat.zero_add, Nat.one_mul] at this

@[simp] protected theorem div_zero (n : Nat) : n / 0 = 0 := by
  rw [div_eq]; simp [Nat.lt_irrefl]

@[simp] protected theorem zero_div (b : Nat) : 0 / b = 0 :=
  (div_eq 0 b).trans <| if_neg <| And.rec Nat.not_le_of_gt

theorem le_div_iff_mul_le (k0 : 0 < k) : x ≤ y / k ↔ x * k ≤ y := by
  induction y, k using mod.inductionOn generalizing x with
    (rw [div_eq]; simp [h]; cases x with simp [zero_le] | succ x => ?_)
  | base y k h =>
    simp [not_succ_le_zero x, succ_mul, Nat.add_comm]
    refine Nat.lt_of_lt_of_le ?_ (Nat.le_add_right ..)
    exact Nat.not_le.1 fun h' => h ⟨k0, h'⟩
  | ind y k h IH =>
    rw [← add_one, Nat.add_le_add_iff_le_right, IH k0, succ_mul,
        ← Nat.add_sub_cancel (x*k) k, Nat.sub_le_sub_right_iff h.2, Nat.add_sub_cancel]

protected theorem div_le_of_le_mul {m n : Nat} : ∀ {k}, m ≤ k * n → m / k ≤ n
  | 0, _ => by simp [Nat.div_zero, n.zero_le]
  | succ k, h => by
    suffices succ k * (m / succ k) ≤ succ k * n from
      Nat.le_of_mul_le_mul_left this (zero_lt_succ _)
    have h1 : succ k * (m / succ k) ≤ m % succ k + succ k * (m / succ k) := Nat.le_add_left _ _
    have h2 : m % succ k + succ k * (m / succ k) = m := by rw [mod_add_div]
    have h3 : m ≤ succ k * n := h
    rw [← h2] at h3
    exact Nat.le_trans h1 h3

theorem div_eq_sub_div (h₁ : 0 < b) (h₂ : b ≤ a) : a / b = (a - b) / b + 1 := by
 rw [div_eq a, if_pos]; constructor <;> assumption

theorem div_eq_of_lt (h₀ : a < b) : a / b = 0 := by
  rw [div_eq a, if_neg]
  intro h₁
  apply Nat.not_le_of_gt h₀ h₁.right

theorem div_lt_iff_lt_mul (Hk : 0 < k) : x / k < y ↔ x < y * k := by
  rw [← Nat.not_le, ← Nat.not_le]; exact not_congr (le_div_iff_mul_le Hk)

/- successor and predecessor -/

theorem add_one_ne_zero (n : Nat) : n + 1 ≠ 0 := succ_ne_zero _

theorem eq_zero_or_eq_succ_pred (n : Nat) : n = 0 ∨ n = succ (pred n) := by
  cases n <;> simp

theorem exists_eq_succ_of_ne_zero {n : Nat} (H : n ≠ 0) : ∃ k, n = succ k :=
  ⟨_, (eq_zero_or_eq_succ_pred _).resolve_left H⟩

theorem succ_eq_one_add (n : Nat) : n.succ = 1 + n := by
  rw [Nat.succ_eq_add_one, Nat.add_comm]

theorem succ_inj' : succ n = succ m ↔ n = m :=
  ⟨succ.inj, congrArg _⟩

/- addition -/

theorem succ_add_eq_succ_add (n m : Nat) : succ n + m = n + succ m := by
  simp [succ_add, add_succ]

theorem one_add (n : Nat) : 1 + n = succ n := by simp [Nat.add_comm]

theorem eq_zero_of_add_eq_zero {n m : Nat} (H : n + m = 0) : n = 0 ∧ m = 0 :=
  ⟨Nat.eq_zero_of_add_eq_zero_right H, Nat.eq_zero_of_add_eq_zero_left H⟩

theorem mul_eq_zero {n m : Nat} : n * m = 0 ↔ n = 0 ∨ m = 0 :=
  ⟨fun h => match n, m, h with
    | 0,   m, _ => .inl rfl
    | n+1, m, h => by rw [succ_mul] at h; exact .inr (Nat.eq_zero_of_add_eq_zero_left h),
   fun | .inl h | .inr h => by simp [h]⟩

/- properties of inequality -/

theorem le_succ_of_pred_le {n m : Nat} : pred n ≤ m → n ≤ succ m :=
  match n with
  | 0 => fun _ => zero_le _
  | _+1 => succ_le_succ

theorem le_lt_antisymm {n m : Nat} (h₁ : n ≤ m) (h₂ : m < n) : False :=
  Nat.lt_irrefl n (Nat.lt_of_le_of_lt h₁ h₂)

theorem lt_le_antisymm {n m : Nat} (h₁ : n < m) (h₂ : m ≤ n) : False :=
  le_lt_antisymm h₂ h₁

protected theorem lt_asymm {n m : Nat} (h₁ : n < m) : ¬ m < n :=
  le_lt_antisymm (Nat.le_of_lt h₁)

/-- Strong case analysis on `a < b ∨ b ≤ a` -/
protected def lt_sum_ge (a b : Nat) : a < b ⊕' b ≤ a :=
  if h : a < b then .inl h else .inr (Nat.not_lt.1 h)

/-- Strong case analysis on `a < b ∨ a = b ∨ b < a` -/
protected def sum_trichotomy (a b : Nat) : a < b ⊕' a = b ⊕' b < a :=
  match a.lt_sum_ge b with
  | .inl h => .inl h
  | .inr h₂ => match b.lt_sum_ge a with
    | .inl h => .inr <| .inr h
    | .inr h₁ => .inr <| .inl <| Nat.le_antisymm h₁ h₂

protected theorem lt_trichotomy (a b : Nat) : a < b ∨ a = b ∨ b < a :=
  match a.sum_trichotomy b with
  | .inl h => .inl h
  | .inr (.inl h) => .inr (.inl h)
  | .inr (.inr h) => .inr (.inr h)

protected theorem eq_or_lt_of_not_lt {a b : Nat} (hnlt : ¬ a < b) : a = b ∨ b < a :=
  (Nat.lt_trichotomy a b).resolve_left hnlt

theorem lt_succ_of_lt (h : a < b) : a < succ b := le_succ_of_le h

theorem one_pos : 0 < 1 := Nat.zero_lt_one

protected theorem not_lt_of_le {n m : Nat} (h₁ : m ≤ n) : ¬ n < m := (Nat.not_le_of_gt · h₁)

protected theorem not_le_of_lt {n m : Nat} : m < n → ¬ n ≤ m := Nat.not_le_of_gt

protected theorem lt_of_not_le {a b : Nat} : ¬ a ≤ b → b < a := (Nat.lt_or_ge b a).resolve_right

protected theorem le_of_not_lt {a b : Nat} : ¬ a < b → b ≤ a := (Nat.lt_or_ge a b).resolve_left

protected theorem le_or_le (a b : Nat) : a ≤ b ∨ b ≤ a := (Nat.lt_or_ge _ _).imp_left Nat.le_of_lt

protected theorem lt_or_eq_of_le {n m : Nat} (h : n ≤ m) : n < m ∨ n = m :=
  (Nat.lt_or_ge _ _).imp_right (Nat.le_antisymm h)

theorem le_zero_iff {i : Nat} : i ≤ 0 ↔ i = 0 :=
  ⟨Nat.eq_zero_of_le_zero, λ h => h ▸ Nat.le_refl i⟩

theorem lt_succ_iff {m n : Nat} : m < succ n ↔ m ≤ n :=
  ⟨le_of_lt_succ, lt_succ_of_le⟩

/- subtraction -/

protected theorem sub_add_eq_max {a b : Nat} : a - b + b = max a b := by
  match a.le_total b with
  | .inl hl => rw [Nat.max_eq_right hl, Nat.sub_eq_zero_iff_le.mpr hl, Nat.zero_add]
  | .inr hr => rw [Nat.max_eq_left hr, Nat.sub_add_cancel hr]

protected theorem sub_le_sub_left (k : Nat) (h : n ≤ m) : k - m ≤ k - n :=
  match m, le.dest h with
  | _, ⟨a, rfl⟩ => by rw [← Nat.sub_sub]; apply sub_le

theorem succ_sub_sub_succ (n m k : Nat) : succ n - m - succ k = n - m - k := by
  rw [Nat.sub_sub, Nat.sub_sub, add_succ, succ_sub_succ]

protected theorem sub.right_comm (m n k : Nat) : m - n - k = m - k - n := by
  rw [Nat.sub_sub, Nat.sub_sub, Nat.add_comm]

protected theorem mul_self_sub_mul_self_eq (a b : Nat) : a * a - b * b = (a + b) * (a - b) := by
  rw [Nat.mul_sub_left_distrib, Nat.right_distrib, Nat.right_distrib,
      Nat.mul_comm b a, Nat.add_comm (a*a) (a*b), Nat.add_sub_add_left]

theorem succ_mul_succ_eq (a b : Nat) : succ a * succ b = a * b + a + b + 1 := by
  rw [mul_succ, succ_mul, Nat.add_right_comm _ a]; rfl

theorem succ_sub {m n : Nat} (h : n ≤ m) : succ m - n = succ (m - n) := by
  let ⟨k, hk⟩ := Nat.le.dest h
  rw [← hk, Nat.add_sub_cancel_left, ← add_succ, Nat.add_sub_cancel_left]

protected theorem sub_pos_of_lt (h : m < n) : 0 < n - m := by
  apply Nat.lt_of_add_lt_add_right (b := m)
  rwa [Nat.zero_add, Nat.sub_add_cancel (Nat.le_of_lt h)]

protected theorem sub_sub_self {n m : Nat} (h : m ≤ n) : n - (n - m) = m :=
  (Nat.sub_eq_iff_eq_add (Nat.sub_le ..)).2 (Nat.add_sub_of_le h).symm

protected theorem sub_add_comm {n m k : Nat} (h : k ≤ n) : n + m - k = n - k + m := by
  rw [Nat.sub_eq_iff_eq_add (Nat.le_trans h (Nat.le_add_right ..))]
  rwa [Nat.add_right_comm, Nat.sub_add_cancel]

theorem sub_one_sub_lt (h : i < n) : n - 1 - i < n := by
  rw [Nat.sub_sub]
  apply Nat.sub_lt (Nat.lt_of_lt_of_le (Nat.zero_lt_succ _) h)
  rw [Nat.add_comm]; apply Nat.zero_lt_succ

theorem pred_inj : ∀ {a b : Nat}, 0 < a → 0 < b → Nat.pred a = Nat.pred b → a = b
| a+1, b+1, _,  _, h => by rw [show a = b from h]
| a+1, 0,   _, hb, _ => absurd hb (Nat.lt_irrefl _)
| 0,   b+1, ha, _, _ => absurd ha (Nat.lt_irrefl _)
| 0,   0,   _,  _, _ => rfl

theorem sub_lt_self {a b : Nat} (h₀ : 0 < a) (h₁ : a ≤ b) : b - a < b := by
  apply sub_lt _ h₀
  apply Nat.lt_of_lt_of_le h₀ h₁

protected theorem add_sub_cancel' {n m : Nat} (h : m ≤ n) : m + (n - m) = n := by
  rw [Nat.add_comm, Nat.sub_add_cancel h]

protected theorem sub_lt_sub_left : ∀ {k m n : Nat}, k < m → k < n → m - n < m - k
  | 0, m+1, n+1, _, _ => by rw [Nat.add_sub_add_right]; exact lt_succ_of_le (Nat.sub_le _ _)
  | k+1, m+1, n+1, h1, h2 => by
    rw [Nat.add_sub_add_right, Nat.add_sub_add_right]
    exact Nat.sub_lt_sub_left (Nat.lt_of_succ_lt_succ h1) (Nat.lt_of_succ_lt_succ h2)

protected theorem sub_lt_left_of_lt_add {n k m : Nat} (H : n ≤ k) (h : k < n + m) : k - n < m := by
  have := Nat.sub_le_sub_right (succ_le_of_lt h) n
  rwa [Nat.add_sub_cancel_left, Nat.succ_sub H] at this

protected theorem add_le_of_le_sub_left {n k m : Nat} (H : m ≤ k) (h : n ≤ k - m) : m + n ≤ k :=
  Nat.not_lt.1 fun h' => Nat.not_lt.2 h (Nat.sub_lt_left_of_lt_add H h')

theorem le_sub_iff_add_le {x y k : Nat} (h : k ≤ y) : x ≤ y - k ↔ x + k ≤ y := by
  rw [← Nat.add_sub_cancel x k, Nat.sub_le_sub_right_iff h, Nat.add_sub_cancel]

theorem le_pred_of_lt {m n : Nat} (h : m < n) : m ≤ n - 1 :=
  Nat.sub_le_sub_right h 1

/- mod -/

theorem le_of_mod_lt {a b : Nat} (h : a % b < a) : b ≤ a :=
  Nat.not_lt.1 fun hf => (ne_of_lt h).elim (Nat.mod_eq_of_lt hf)

@[simp] theorem add_mod_right (x z : Nat) : (x + z) % z = x % z := by
  rw [mod_eq_sub_mod (Nat.le_add_left ..), Nat.add_sub_cancel]

@[simp] theorem add_mod_left (x z : Nat) : (x + z) % x = z % x := by
  rw [Nat.add_comm, add_mod_right]

@[simp] theorem add_mul_mod_self_left (x y z : Nat) : (x + y * z) % y = x % y := by
  match z with
  | 0 => rw [Nat.mul_zero, Nat.add_zero]
  | succ z => rw [mul_succ, ← Nat.add_assoc, add_mod_right, add_mul_mod_self_left (z := z)]

@[simp] theorem add_mul_mod_self_right (x y z : Nat) : (x + y * z) % z = x % z := by
  rw [Nat.mul_comm, add_mul_mod_self_left]

@[simp] theorem mul_mod_right (m n : Nat) : (m * n) % m = 0 := by
  rw [← Nat.zero_add (m * n), add_mul_mod_self_left, zero_mod]

@[simp] theorem mul_mod_left (m n : Nat) : (m * n) % n = 0 := by
  rw [Nat.mul_comm, mul_mod_right]

theorem mul_mod_mul_left (z x y : Nat) : (z * x) % (z * y) = z * (x % y) :=
  if y0 : y = 0 then by
    rw [y0, Nat.mul_zero, mod_zero, mod_zero]
  else if z0 : z = 0 then by
    rw [z0, Nat.zero_mul, Nat.zero_mul, Nat.zero_mul, mod_zero]
  else by
    induction x using Nat.strongInductionOn with
    | _ n IH =>
      have y0 : y > 0 := Nat.pos_of_ne_zero y0
      have z0 : z > 0 := Nat.pos_of_ne_zero z0
      cases Nat.lt_or_ge n y with
      | inl yn => rw [mod_eq_of_lt yn, mod_eq_of_lt (Nat.mul_lt_mul_of_pos_left yn z0)]
      | inr yn =>
        rw [mod_eq_sub_mod yn, mod_eq_sub_mod (Nat.mul_le_mul_left z yn),
          ← Nat.mul_sub_left_distrib]
        exact IH _ (sub_lt (Nat.lt_of_lt_of_le y0 yn) y0)

theorem mul_mod_mul_right (z x y : Nat) : (x * z) % (y * z) = (x % y) * z := by
  rw [Nat.mul_comm x z, Nat.mul_comm y z, Nat.mul_comm (x % y) z]; apply mul_mod_mul_left

-- TODO cont_to_bool_mod_two

theorem sub_mul_mod {x k n : Nat} (h₁ : n*k ≤ x) : (x - n*k) % n = x % n := by
  match k with
  | 0 => rw [Nat.mul_zero, Nat.sub_zero]
  | succ k =>
    have h₂ : n * k ≤ x := Nat.le_trans (le_add_right _ n) h₁
    have h₄ : x - n * k ≥ n := by
      apply Nat.le_of_add_le_add_right (b := n * k)
      rw [Nat.sub_add_cancel h₂]
      simp [mul_succ, Nat.add_comm] at h₁; simp [h₁]
    rw [mul_succ, ← Nat.sub_sub, ← mod_eq_sub_mod h₄, sub_mul_mod h₂]

/- div -/

theorem sub_mul_div (x n p : Nat) (h₁ : n*p ≤ x) : (x - n*p) / n = x / n - p := by
  match eq_zero_or_pos n with
  | .inl h₀ => rw [h₀, Nat.div_zero, Nat.div_zero, Nat.zero_sub]
  | .inr h₀ => induction p with
    | zero => rw [Nat.mul_zero, Nat.sub_zero, Nat.sub_zero]
    | succ p IH =>
      have h₂ : n * p ≤ x := Nat.le_trans (Nat.mul_le_mul_left _ (le_succ _)) h₁
      have h₃ : x - n * p ≥ n := by
        apply Nat.le_of_add_le_add_right
        rw [Nat.sub_add_cancel h₂, Nat.add_comm]
        rw [mul_succ] at h₁
        exact h₁
      rw [sub_succ, ← IH h₂, div_eq_sub_div h₀ h₃]
      simp [add_one, Nat.pred_succ, mul_succ, Nat.sub_sub]

theorem div_mul_le_self : ∀ (m n : Nat), m / n * n ≤ m
  | m, 0   => by simp
  | m, n+1 => (le_div_iff_mul_le (Nat.succ_pos _)).1 (Nat.le_refl _)

@[simp] theorem add_div_right (x : Nat) {z : Nat} (H : 0 < z) : (x + z) / z = succ (x / z) := by
  rw [div_eq_sub_div H (Nat.le_add_left _ _), Nat.add_sub_cancel]

@[simp] theorem add_div_left (x : Nat) {z : Nat} (H : 0 < z) : (z + x) / z = succ (x / z) := by
  rw [Nat.add_comm, add_div_right x H]

@[simp] theorem mul_div_right (n : Nat) {m : Nat} (H : 0 < m) : m * n / m = n := by
  induction n <;> simp_all [mul_succ]

@[simp] theorem mul_div_left (m : Nat) {n : Nat} (H : 0 < n) : m * n / n = m := by
  rw [Nat.mul_comm, mul_div_right _ H]

protected theorem div_self (H : 0 < n) : n / n = 1 := by
  let t := add_div_right 0 H
  rwa [Nat.zero_add, Nat.zero_div] at t

theorem add_mul_div_left (x z : Nat) {y : Nat} (H : 0 < y) : (x + y * z) / y = x / y + z := by
  induction z with
  | zero => rw [Nat.mul_zero, Nat.add_zero, Nat.add_zero]
  | succ z ih => rw [mul_succ, ← Nat.add_assoc, add_div_right _ H, ih]; rfl

theorem add_mul_div_right (x y : Nat) {z : Nat} (H : 0 < z) : (x + y * z) / z = x / z + y := by
  rw [Nat.mul_comm, add_mul_div_left _ _ H]

protected theorem mul_div_cancel (m : Nat) {n : Nat} (H : 0 < n) : m * n / n = m := by
  let t := add_mul_div_right 0 m H
  rwa [Nat.zero_add, Nat.zero_div, Nat.zero_add] at t

protected theorem mul_div_cancel_left (m : Nat) {n : Nat} (H : 0 < n) : n * m / n = m :=
by rw [Nat.mul_comm, Nat.mul_div_cancel _ H]

protected theorem div_eq_of_eq_mul_left (H1 : 0 < n) (H2 : m = k * n) : m / n = k :=
by rw [H2, Nat.mul_div_cancel _ H1]

protected theorem div_eq_of_eq_mul_right (H1 : 0 < n) (H2 : m = n * k) : m / n = k :=
by rw [H2, Nat.mul_div_cancel_left _ H1]

protected theorem div_eq_of_lt_le (lo : k * n ≤ m) (hi : m < succ k * n) : m / n = k :=
have npos : 0 < n := (eq_zero_or_pos _).resolve_left fun hn => by
  rw [hn, Nat.mul_zero] at hi lo; exact absurd lo (Nat.not_le_of_gt hi)
Nat.le_antisymm
  (le_of_lt_succ ((Nat.div_lt_iff_lt_mul npos).2 hi))
  ((Nat.le_div_iff_mul_le npos).2 lo)

theorem mul_sub_div (x n p : Nat) (h₁ : x < n*p) : (n * p - succ x) / n = p - succ (x / n) := by
  have npos : 0 < n := (eq_zero_or_pos _).resolve_left fun n0 => by
    rw [n0, Nat.zero_mul] at h₁; exact not_lt_zero _ h₁
  apply Nat.div_eq_of_lt_le
  · rw [Nat.mul_sub_right_distrib, Nat.mul_comm]
    exact Nat.sub_le_sub_left _ <| (div_lt_iff_lt_mul npos).1 (lt_succ_self _)
  · show succ (pred (n * p - x)) ≤ (succ (pred (p - x / n))) * n
    rw [succ_pred_eq_of_pos (Nat.sub_pos_of_lt h₁),
      fun h => succ_pred_eq_of_pos (Nat.sub_pos_of_lt h)] -- TODO: why is the function needed?
    · rw [Nat.mul_sub_right_distrib, Nat.mul_comm]
      exact Nat.sub_le_sub_left _ <| div_mul_le_self ..
    · rwa [div_lt_iff_lt_mul npos, Nat.mul_comm]

protected theorem div_div_eq_div_mul (m n k : Nat) : m / n / k = m / (n * k) := by
  cases eq_zero_or_pos k with
  | inl k0 => rw [k0, Nat.mul_zero, Nat.div_zero, Nat.div_zero] | inr kpos => ?_
  cases eq_zero_or_pos n with
  | inl n0 => rw [n0, Nat.zero_mul, Nat.div_zero, Nat.zero_div] | inr npos => ?_
  apply Nat.le_antisymm
  · apply (le_div_iff_mul_le (Nat.mul_pos npos kpos)).2
    rw [Nat.mul_comm n k, ← Nat.mul_assoc]
    apply (le_div_iff_mul_le npos).1
    apply (le_div_iff_mul_le kpos).1
    (apply Nat.le_refl)
  · apply (le_div_iff_mul_le kpos).2
    apply (le_div_iff_mul_le npos).2
    rw [Nat.mul_assoc, Nat.mul_comm n k]
    apply (le_div_iff_mul_le (Nat.mul_pos kpos npos)).1
    apply Nat.le_refl

protected theorem mul_div_mul {m : Nat} (n k : Nat) (H : 0 < m) : m * n / (m * k) = n / k := by
  rw [← Nat.div_div_eq_div_mul, Nat.mul_div_cancel_left _ H]

theorem mul_div_le (m n : Nat) : n * (m / n) ≤ m := by
  match n, Nat.eq_zero_or_pos n with
  | _, Or.inl rfl => rw [Nat.zero_mul]; exact m.zero_le
  | n, Or.inr h => rw [Nat.mul_comm, ← Nat.le_div_iff_mul_le h]; exact Nat.le_refl _

/- dvd -/

protected theorem dvd_refl (a : Nat) : a ∣ a := ⟨1, by simp⟩

protected theorem dvd_zero (a : Nat) : a ∣ 0 := ⟨0, by simp⟩

protected theorem dvd_mul_left (a b : Nat) : a ∣ b * a := ⟨b, Nat.mul_comm b a⟩

protected theorem dvd_mul_right (a b : Nat) : a ∣ a * b := ⟨b, rfl⟩

protected theorem dvd_trans {a b c : Nat} (h₁ : a ∣ b) (h₂ : b ∣ c) : a ∣ c :=
  match h₁, h₂ with
  | ⟨d, (h₃ : b = a * d)⟩, ⟨e, (h₄ : c = b * e)⟩ =>
    ⟨d * e, show c = a * (d * e) by simp[h₃,h₄, Nat.mul_assoc]⟩

protected theorem eq_zero_of_zero_dvd {a : Nat} (h : 0 ∣ a) : a = 0 :=
  let ⟨c, H'⟩ := h; H'.trans c.zero_mul

protected theorem dvd_add {a b c : Nat} (h₁ : a ∣ b) (h₂ : a ∣ c) : a ∣ b + c :=
  let ⟨d, hd⟩ := h₁; let ⟨e, he⟩ := h₂; ⟨d + e, by simp [Nat.left_distrib, hd, he]⟩

protected theorem dvd_add_iff_right {k m n : Nat} (h : k ∣ m) : k ∣ n ↔ k ∣ m + n :=
  ⟨Nat.dvd_add h,
    match m, h with
    | _, ⟨d, rfl⟩ => fun ⟨e, he⟩ =>
      ⟨e - d, by rw [Nat.mul_sub_left_distrib, ←he, Nat.add_sub_cancel_left]⟩⟩

protected theorem dvd_add_iff_left {k m n : Nat} (h : k ∣ n) : k ∣ m ↔ k ∣ m + n := by
  rw [Nat.add_comm]; exact Nat.dvd_add_iff_right h

theorem dvd_sub {k m n : Nat} (H : n ≤ m) (h₁ : k ∣ m) (h₂ : k ∣ n) : k ∣ m - n :=
  (Nat.dvd_add_iff_left h₂).2 <| by rwa [Nat.sub_add_cancel H]

protected theorem mul_dvd_mul {a b c d : Nat} : a ∣ b → c ∣ d → a * c ∣ b * d
  | ⟨e, he⟩, ⟨f, hf⟩ =>
    ⟨e * f, by simp [he, hf, Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm]⟩

protected theorem mul_dvd_mul_left (a : Nat) (h : b ∣ c) : a * b ∣ a * c :=
  Nat.mul_dvd_mul (Nat.dvd_refl a) h

protected theorem mul_dvd_mul_right (h: a ∣ b) (c : Nat) : a * c ∣ b * c :=
  Nat.mul_dvd_mul h (Nat.dvd_refl c)

theorem dvd_mod_iff {k m n : Nat} (h: k ∣ n) : k ∣ m % n ↔ k ∣ m :=
  have := Nat.dvd_add_iff_left <| Nat.dvd_trans h <| Nat.dvd_mul_right n (m / n)
  by rwa [mod_add_div] at this

theorem le_of_dvd {m n : Nat} (h : 0 < n) : m ∣ n → m ≤ n
  | ⟨k, e⟩ => by
    revert h
    rw [e]
    match k with
    | 0 => intro hn; simp at hn
    | pk+1 =>
      intro
      have := Nat.mul_le_mul_left m (succ_pos pk)
      rwa [Nat.mul_one] at this

theorem dvd_antisymm : ∀ {m n : Nat}, m ∣ n → n ∣ m → m = n
  | _, 0, _, h₂ => Nat.eq_zero_of_zero_dvd h₂
  | 0, _, h₁, _ => (Nat.eq_zero_of_zero_dvd h₁).symm
  | _+1, _+1, h₁, h₂ => Nat.le_antisymm (le_of_dvd (succ_pos _) h₁) (le_of_dvd (succ_pos _) h₂)

theorem pos_of_dvd_of_pos {m n : Nat} (H1 : m ∣ n) (H2 : 0 < n) : 0 < m :=
  Nat.pos_of_ne_zero fun m0 => Nat.ne_of_gt H2 <| Nat.eq_zero_of_zero_dvd (m0 ▸ H1)

theorem eq_one_of_dvd_one {n : Nat} (H : n ∣ 1) : n = 1 :=
  Nat.le_antisymm (le_of_dvd (by decide) H) (pos_of_dvd_of_pos H (by decide))

theorem dvd_of_mod_eq_zero {m n : Nat} (H : n % m = 0) : m ∣ n := by
  exists n / m
  have := (mod_add_div n m).symm
  rwa [H, Nat.zero_add] at this

theorem mod_eq_zero_of_dvd {m n : Nat} (H : m ∣ n) : n % m = 0 := by
  let ⟨z, H⟩ := H; rw [H, mul_mod_right]

theorem dvd_iff_mod_eq_zero (m n : Nat) : m ∣ n ↔ n % m = 0 :=
  ⟨mod_eq_zero_of_dvd, dvd_of_mod_eq_zero⟩

instance decidable_dvd : @DecidableRel Nat (·∣·) :=
  fun _ _ => decidable_of_decidable_of_iff (dvd_iff_mod_eq_zero _ _).symm

protected theorem mul_div_cancel' {n m : Nat} (H : n ∣ m) : n * (m / n) = m := by
  have := mod_add_div m n
  rwa [mod_eq_zero_of_dvd H, Nat.zero_add] at this

protected theorem div_mul_cancel {n m : Nat} (H : n ∣ m) : m / n * n = m := by
  rw [Nat.mul_comm, Nat.mul_div_cancel' H]

protected theorem mul_div_assoc (m : Nat) (H : k ∣ n) : m * n / k = m * (n / k) := by
  match Nat.eq_zero_or_pos k with
  | .inl h0 => rw [h0, Nat.div_zero, Nat.div_zero, Nat.mul_zero]
  | .inr hpos =>
    have h1 : m * n / k = m * (n / k * k) / k := by rw [Nat.div_mul_cancel H]
    rw [h1, ← Nat.mul_assoc, Nat.mul_div_cancel _ hpos]

protected theorem dvd_of_mul_dvd_mul_left
    (kpos : 0 < k) (H : k * m ∣ k * n) : m ∣ n := by
  let ⟨l, H⟩ := H
  rw [Nat.mul_assoc] at H
  exact ⟨_, Nat.eq_of_mul_eq_mul_left kpos H⟩

protected theorem dvd_of_mul_dvd_mul_right (kpos : 0 < k) (H : m * k ∣ n * k) : m ∣ n := by
  rw [Nat.mul_comm m k, Nat.mul_comm n k] at H; exact Nat.dvd_of_mul_dvd_mul_left kpos H

/- --- -/

protected theorem mul_le_mul_of_nonneg_left {a b c : Nat} (h₁ : a ≤ b) : c * a ≤ c * b := by
  by_cases hba: b ≤ a; { simp [Nat.le_antisymm hba h₁] }
  by_cases hc0 : c ≤ 0; { simp [Nat.le_antisymm hc0 (zero_le c), Nat.zero_mul] }
  exact Nat.le_of_lt (Nat.mul_lt_mul_of_pos_left (Nat.not_le.1 hba) (Nat.not_le.1 hc0))

protected theorem mul_le_mul_of_nonneg_right {a b c : Nat} (h₁ : a ≤ b) : a * c ≤ b * c := by
  by_cases hba : b ≤ a; { simp [Nat.le_antisymm hba h₁] }
  by_cases hc0 : c ≤ 0; { simp [Nat.le_antisymm hc0 (zero_le c), Nat.mul_zero] }
  exact Nat.le_of_lt (Nat.mul_lt_mul_of_pos_right (Nat.not_le.1 hba) (Nat.not_le.1 hc0))

protected theorem mul_lt_mul (hac : a < c) (hbd : b ≤ d) (pos_b : 0 < b) : a * b < c * d :=
  Nat.lt_of_lt_of_le (Nat.mul_lt_mul_of_pos_right hac pos_b) (Nat.mul_le_mul_of_nonneg_left hbd)

protected theorem mul_lt_mul' (h1 : a ≤ c) (h2 : b < d) (h3 : 0 < c) : a * b < c * d :=
  Nat.lt_of_le_of_lt (Nat.mul_le_mul_of_nonneg_right h1) (Nat.mul_lt_mul_of_pos_left h2 h3)

@[simp] theorem mod_mod (a n : Nat) : (a % n) % n = a % n :=
  match eq_zero_or_pos n with
  | .inl n0 => by simp [n0, mod_zero]
  | .inr npos => Nat.mod_eq_of_lt (mod_lt _ npos)

theorem mul_mod (a b n : Nat) : a * b % n = (a % n) * (b % n) % n := by
  conv => lhs; rw [
    ← mod_add_div a n, ← mod_add_div b n, Nat.add_mul, Nat.mul_add, Nat.mul_add,
    Nat.mul_assoc, Nat.mul_assoc, ← Nat.mul_add n, add_mul_mod_self_left,
    Nat.mul_comm _ (n * (b / n)), Nat.mul_assoc, add_mul_mod_self_left]

@[simp] theorem mod_add_mod (m n k : Nat) : (m % n + k) % n = (m + k) % n := by
  have := (add_mul_mod_self_left (m % n + k) n (m / n)).symm
  rwa [Nat.add_right_comm, mod_add_div] at this

@[simp] theorem add_mod_mod (m n k : Nat) : (m + n % k) % k = (m + n) % k := by
  rw [Nat.add_comm, mod_add_mod, Nat.add_comm]

theorem add_mod (a b n : Nat) : (a + b) % n = ((a % n) + (b % n)) % n := by
  rw [add_mod_mod, mod_add_mod]

theorem pow_succ' {m n : Nat} : m ^ n.succ = m * m ^ n := by
  rw [Nat.pow_succ, Nat.mul_comm]

@[simp] theorem pow_eq {m n : Nat} : m.pow n = m ^ n := rfl

@[simp] theorem shiftLeft_eq (a b : Nat) : a <<< b = a * 2 ^ b :=
  match b with
  | 0 => (Nat.mul_one _).symm
  | b+1 => (shiftLeft_eq _ b).trans <| by
    simp [pow_succ, Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm]

theorem one_shiftLeft (n : Nat) : 1 <<< n = 2 ^ n := by rw [shiftLeft_eq, Nat.one_mul]
