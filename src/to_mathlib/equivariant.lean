import notations
import topology.algebra.floor_ring
import to_mathlib.topology.misc

noncomputable theory

open set function finite_dimensional prod int
open_locale topological_space unit_interval

/-- Equivariant maps from `ℝ` to itself are functions `f : ℝ → ℝ` with `f (t + 1) = f t + 1`. -/
structure equivariant_map :=
(to_fun : ℝ → ℝ)
(eqv' : ∀ t, to_fun (t + 1) = to_fun t + 1)

namespace equivariant_map

variable (φ : equivariant_map)

instance : has_coe_to_fun equivariant_map (λ _, ℝ → ℝ) := ⟨equivariant_map.to_fun⟩

lemma eqv : ∀ t, φ (t + 1) = φ t + 1 := φ.eqv'

lemma sub_one (t : ℝ) : φ (t - 1) = φ t - 1 :=
by rw [eq_sub_iff_add_eq, ← eqv, sub_add_cancel]

lemma add_coe (t : ℝ) (n : ℤ) : φ (t + n) = φ t + n :=
begin
  refine int.induction_on' n 0 _ _ _,
  { simp_rw [cast_zero, add_zero] },
  { intros k hk h, simp_rw [cast_add, cast_one, ← add_assoc, eqv, h] },
  { intros k hk h, simp_rw [cast_sub, cast_one, ← add_sub_assoc, sub_one, h] }
end

lemma coe_int (n : ℤ) : φ n = φ 0 + n :=
by { convert add_coe φ 0 n, rw [zero_add] }

protected lemma not_bounded_above (y : ℝ) : ∃ (x : ℝ), y ≤ φ x  :=
by { use int.ceil (y - φ 0), simp_rw [φ.coe_int, ← sub_le_iff_le_add', le_ceil] }

protected lemma not_bounded_below (y : ℝ) : ∃ (x : ℝ), φ x ≤ y  :=
by { use int.floor (y - φ 0), simp_rw [φ.coe_int, ← le_sub_iff_add_le', floor_le] }

@[simp] lemma coe_mk (f : ℝ → ℝ) {eqv} : ((⟨f, eqv⟩ : equivariant_map) : ℝ → ℝ) = f := rfl

protected lemma surjective (h : continuous φ) : surjective φ :=
begin
  rw [← range_iff_surjective, eq_univ_iff_forall],
  exact λ y, mem_range_of_exists_le_of_exists_ge h (φ.not_bounded_below y) (φ.not_bounded_above y)
end

end equivariant_map

@[simp] lemma fract_add_one {α} [linear_ordered_ring α] [floor_ring α] (a : α) :
  fract (a + 1) = fract a :=
by exact_mod_cast fract_add_int a 1

/-- continuous equivariant reparametrization that is locally constant around `0`.
  It linearly connects `(0, 0)`, `(1/4, 0)` and `(3/4, 1)` and `(1, 1)` and is extended to an
  equivariant function. -/
def linear_reparam : equivariant_map :=
⟨λ x, ⌊ x ⌋ + max 0 (min 1 $ 2 * (fract x - 4⁻¹)), λ t,
  by simp [floor_add_one, add_sub, ← sub_add_eq_add_sub _ _ (1 : ℝ), fract_add_one, add_right_comm]⟩

lemma linear_reparam_eq_zero {t : ℝ} (h1 : 0 ≤ t) (h2 : t ≤ 4⁻¹) : linear_reparam t = 0 :=
begin
  have : ⌊ t ⌋ = 0 := floor_eq_iff.mpr ⟨h1, h2.trans_lt $ by norm_num⟩,
  simp [linear_reparam, fract, -self_sub_floor, mul_nonpos_iff, *],
end

@[simp] lemma linear_reparam_zero : linear_reparam 0 = 0 :=
linear_reparam_eq_zero le_rfl $ by norm_num

lemma max_eq_of_lt_left {a b c : ℝ} (h : a < c) : max a b = c ↔ b = c :=
by simp [max_eq_iff, h.ne, h.le] {contextual := tt}

lemma linear_reparam_eq_one {t : ℝ} (h1 : 3 / 4 ≤ t) (h2 : t ≤ 1) : linear_reparam t = 1 :=
begin
  rcases h2.lt_or_eq with h2|rfl,
  { have : ⌊ t ⌋ = 0 := floor_eq_iff.mpr ⟨le_trans (by norm_num) h1, h2.trans_le (by norm_num)⟩,
    simp [linear_reparam, fract, -self_sub_floor, max_eq_of_lt_left, this], field_simp, linarith },
  { have : fract (1 : ℝ) = 0 := by { convert fract_coe 1, norm_cast },
    norm_num [linear_reparam, this] }
end

@[simp] lemma linear_reparam_one : linear_reparam 1 = 1 :=
linear_reparam_eq_one (by norm_num) le_rfl

@[simp] lemma linear_reparam_proj_I (t : ℝ) :
  linear_reparam (proj_I t) = proj_I (linear_reparam t) :=
sorry

lemma continuous_linear_reparam : continuous linear_reparam :=
sorry
-- continuous_on.comp_fract _ _ _

set_option old_structure_cmd true

structure equivariant_equiv extends ℝ ≃ ℝ :=
(map_zero' : to_fun 0 = 0)
(eqv' : ∀ t, to_fun (t + 1) = to_fun t + 1)

namespace equivariant_equiv

variable (φ : equivariant_equiv)

instance : has_coe_to_fun equivariant_equiv (λ _, ℝ → ℝ) := ⟨λ f, f.to_fun⟩

instance has_coe_to_equiv : has_coe equivariant_equiv (ℝ ≃ ℝ) := ⟨to_equiv⟩

@[simps]
protected def equivariant_map : equivariant_map := { to_fun := φ, ..φ }

lemma eqv : ∀ t, φ (t + 1) = φ t + 1 := φ.eqv'

@[simp] lemma map_zero : φ 0 = 0 := φ.map_zero'

@[simp] lemma map_one : φ 1 = 1 :=
by conv_lhs { rw [← zero_add (1 : ℝ), eqv, map_zero, zero_add], }

instance {α : Type*} : has_uncurry (α → equivariant_equiv) (α × ℝ) ℝ := ⟨λ φ p, φ p.1 p.2⟩

@[simp] lemma coe_mk (f : ℝ → ℝ) (g : ℝ → ℝ) (h₀ h₁ h₂ h₃) :
  ⇑(⟨f, g, h₀, h₁, h₂, h₃⟩ : equivariant_equiv) = f :=
rfl

@[simp] lemma coe_to_equiv (e : equivariant_equiv) : (⇑(e : ℝ ≃ ℝ) : ℝ → ℝ) = e := rfl

def symm (e : equivariant_equiv) : equivariant_equiv :=
{ map_zero' := by rw [← (e : ℝ ≃ ℝ).apply_eq_iff_eq, equiv.to_fun_as_coe, equiv.apply_symm_apply,
    coe_to_equiv, map_zero],
  eqv' := λ t,
  begin
    let f := (e : ℝ ≃ ℝ),
    let g := (e : ℝ ≃ ℝ).symm,
    change g (t + 1) = g t + 1,
    calc g (t + 1) = g (f (g t) + 1) : by rw (e : ℝ ≃ ℝ).apply_symm_apply
               ... = g (f (g t + 1)) : by { erw e.eqv, refl, }
               ... = g t + 1 : (e : ℝ ≃ ℝ).symm_apply_apply _,
  end,
  .. (e : ℝ ≃ ℝ).symm }

instance : equiv_like equivariant_equiv ℝ ℝ :=
{ coe := to_fun, inv := inv_fun, left_inv := left_inv, right_inv := right_inv,
  coe_injective' := λ e₁ e₂ h₁ h₂, by { cases e₁, cases e₂, congr', } }

@[ext] lemma ext {e₁ e₂ : equivariant_equiv} (h : ∀ x, e₁ x = e₂ x) : e₁ = e₂ :=
fun_like.ext e₁ e₂ h

@[simp] lemma symm_symm (e : equivariant_equiv) : e.symm.symm = e :=
begin
  ext x,
  change (e : ℝ ≃ ℝ).symm.symm x = e x,
  simp only [equiv.symm_symm, coe_to_equiv],
end

@[simp] lemma apply_symm_apply (e : equivariant_equiv) : ∀ x, e (e.symm x) = x :=
(e : ℝ ≃ ℝ).apply_symm_apply

@[simp] lemma symm_apply_apply (e : equivariant_equiv) : ∀ x, e.symm (e x) = x :=
(e : ℝ ≃ ℝ).symm_apply_apply

end equivariant_equiv
