import loops.reparametrization

import local.corrugation
import local.relation

/-!
# Local h-principle for open and ample relations

This file proves lem:h_principle_open_ample_loc
-/

noncomputable theory

open_locale unit_interval classical filter topological_space
open filter set rel_loc

-- `∀ᶠ x near s, p x` means property `p` holds at every point in a neighborhood of the set `s`.
local notation `∀ᶠ` binders ` near ` s `, ` r:(scoped p, filter.eventually p $ 𝓝ˢ s) := r

local notation `D` := fderiv ℝ
local notation `𝒞` := times_cont_diff ℝ
local notation `∞` := ⊤
local notation `hull` := convex_hull ℝ
local notation u ` ⬝ `:70 φ:65 :=
  continuous_linear_map.comp (continuous_linear_map.to_span_singleton ℝ u) φ


variables (E : Type*) [normed_group E] [normed_space ℝ E] [finite_dimensional ℝ E]
          {F : Type*} [normed_group F] [normed_space ℝ F] [measurable_space F] [borel_space F]
          [finite_dimensional ℝ F]

open_locale unit_interval
/--
The setup for local h-principle is three nested subsets `K₀ ⊆ K₁ ⊆ U` with `U` open,
`K₀` and `K₁` compact, `K₀ ⊆ interior K₁` and a closed subset `C`.
-/
structure landscape :=
(U C K₀ K₁ : set E)
(hU : is_open U)
(hC : is_closed C)
(hK₀ : is_compact K₀)
(hK₁ : is_compact K₁)
(h₀₁ : K₀ ⊆ interior K₁)
(hK₁U : K₁ ⊆ U)

section improve_step
/-!
## Improvement step

This section proves lem:integration_step.
-/

/--
The setup for a one-step improvement towards a local h-principle is three nested subsets
`K₀ ⊆ K₁ ⊆ U` with `U` open, `K₀` and `K₁` compact, `K₀ ⊆ interior K₁` and a closed subset `C`
together with a dual pair `p` and a subspace `E'` of the corresponding hyperplane `ker p.π`.
-/
structure step_landscape extends landscape E :=
(E' : submodule ℝ E)
(p : dual_pair' E)
(hEp : E' ≤ p.π.ker)

variables {E}

open_locale classical

variables (R : rel_loc E F) --{U : set E}

namespace step_landscape

/-- A one-step improvement landscape accepts a formal solution if it can improve it. -/
structure accepts (L : step_landscape E) (𝓕 : jet_sec L.U F) : Prop :=
(h_op : R.is_open_over L.U)
(hK₀ : ∀ᶠ x near L.K₀, 𝓕.is_part_holonomic_at L.E' x)
(h_short : ∀ x ∈ L.U, 𝓕.is_short_at R L.p x)
(hC : ∀ᶠ x near L.C, 𝓕.is_holonomic_at x)

def Ω (L : step_landscape E) (𝓕 : jet_sec L.U F) : set (E × F) :=
⋃ x ∈ L.U, ({x} : set E) ×ˢ (connected_comp_in (𝓕.slice_at R L.p x) $ 𝓕.φ x L.p.v)

def π (L : step_landscape E) : E →L[ℝ] ℝ := L.p.π

def v (L : step_landscape E) : E := L.p.v

def K (L : step_landscape E) : set E := L.K₁ ∩ L.C

def b (L : step_landscape E) (𝓕 : jet_sec L.U F) : E → F := λ x, 𝓕.φ x L.v

def g (L : step_landscape E) (𝓕 : jet_sec L.U F) : E → F := λ x, D 𝓕.f x L.v

lemma is_compact_K (L : step_landscape E) : is_compact L.K :=
L.hK₁.inter_right L.hC

lemma hKU (L : step_landscape E) : L.K ⊆ L.U :=
((inter_subset_left _ _).trans L.hK₁U)

variables {R}

lemma mem_Ω {L : step_landscape E} {𝓕 : jet_sec L.U F} {x : E} {w : F} (H : (x, w) ∈ L.Ω R 𝓕) :
  (x, 𝓕.f x, L.p.update (𝓕.φ x) w) ∈ R :=
begin
  obtain ⟨x, -, h, rfl⟩ : ∃ x', x' ∈ L.U ∧
                                w ∈ connected_comp_in (𝓕.slice_at R L.p x') (𝓕.φ x' L.p.v) ∧ x' = x,
  by simpa [step_landscape.Ω] using H,
  exact (connected_comp_in_subset _ _ h : _)
end

lemma accepts.open {L : step_landscape E} {𝓕 : jet_sec L.U F} (h : L.accepts R 𝓕) :
  is_open (L.Ω R 𝓕 ∩ (L.U ×ˢ (univ : set F))) :=
sorry

lemma accepts.connected {L : step_landscape E} {𝓕 : formal_sol R L.U} (h : L.accepts R 𝓕) :
  ∀ x ∈ L.U, is_connected (prod.mk x ⁻¹' (L.Ω R 𝓕)) :=
begin

  sorry
end

lemma accepts.smooth_b {L : step_landscape E} {𝓕 : jet_sec L.U F} (h : L.accepts R 𝓕) :
  ∀ x ∈ L.U, smooth_at (L.b 𝓕) x :=
sorry

lemma accepts.smooth_g {L : step_landscape E} {𝓕 : jet_sec L.U F} (h : L.accepts R 𝓕) :
  ∀ x ∈ L.U, smooth_at (L.g 𝓕) x :=
sorry

lemma accepts.mem {L : step_landscape E} {𝓕 : jet_sec L.U F} (h : L.accepts R 𝓕) :
  ∀ x ∈ L.U, (x, L.b 𝓕 x) ∈ L.Ω R 𝓕 :=
sorry

lemma accepts.rel {L : step_landscape E} {𝓕 : jet_sec L.U F} (h : L.accepts R 𝓕) :
  ∀ᶠ (x : E) near L.K, (L.g 𝓕) x = (L.b 𝓕) x :=
sorry

lemma accepts.hull {L : step_landscape E} {𝓕 : jet_sec L.U F} (h : L.accepts R 𝓕) :
  ∀ x ∈ L.U, L.g 𝓕 x ∈ hull (prod.mk x ⁻¹' L.Ω R 𝓕) :=
sorry

-- The next lemma uses compactnes of K₁, openness of R above U and continuity of 𝓕
lemma mem_of_c0_close (L : step_landscape E) (𝓕 : htpy_jet_sec L.U F)
  (h_op : R.is_open_over L.U) (h_sol : ∀ t, (𝓕 t).is_formal_sol R) :
  ∃ ε > 0, ∀ (x : E) (z : F) (ψ : E →L[ℝ] F) (t : ℝ),
           x ∈ L.K₁ → ∥z - (𝓕 t).f x∥ < ε → ∥ψ - (𝓕 t).φ x∥ < ε → (x, z, ψ) ∈ R :=
sorry

/-- The loop family to use in some landscape to improve a formal solution. -/
def loop (L : step_landscape E) {𝓕 : formal_sol R L.U} (h : L.accepts R 𝓕) :
ℝ → E → loop F :=
classical.some (exists_loops L.hU L.is_compact_K L.hKU h.open h.connected h.smooth_g
                             h.smooth_b h.mem h.rel h.hull)

lemma loop_mem (L : step_landscape E) {𝓕 : formal_sol R L.U} (h : L.accepts R 𝓕) :
∀ (x ∈ L.U) t s, L.loop h t x s ∈ (prod.mk x ⁻¹' L.Ω R 𝓕) :=
λ x x_in t s,
(((classical.some_spec $ exists_loops L.hU L.is_compact_K L.hKU h.open h.connected h.smooth_g
                             h.smooth_b h.mem h.rel h.hull).2.2.1 x x_in).2.2 t s).1

lemma loop_base (L : step_landscape E) {𝓕 : formal_sol R L.U} (h : L.accepts R 𝓕) :
∀ (x ∈ L.U) s, L.loop h 0 x s = L.b 𝓕 x :=
λ x x_in s,
  ((classical.some_spec (exists_loops L.hU L.is_compact_K L.hKU h.open h.connected h.smooth_g
                             h.smooth_b h.mem h.rel h.hull)).2.2.1 x x_in).1 s

lemma loop_smooth (L : step_landscape E) {𝓕 : formal_sol R L.U} (h : L.accepts R 𝓕) :
∀ (x ∈ L.U) t s, smooth_at ↿(L.loop h) ((t, x, s) : ℝ × E × ℝ) :=
λ x x_in t s,
(((classical.some_spec $ exists_loops L.hU L.is_compact_K L.hKU h.open h.connected h.smooth_g
                             h.smooth_b h.mem h.rel h.hull).2.2.1 x x_in).2.2 t s).2

lemma loop_avg (L : step_landscape E) {𝓕 : formal_sol R L.U} (h : L.accepts R 𝓕) :
 ∀ (x ∈ L.U), (L.loop h 1 x).average = L.g 𝓕 x :=
λ x x_in,
((classical.some_spec $ exists_loops L.hU L.is_compact_K L.hKU h.open h.connected h.smooth_g
                             h.smooth_b h.mem h.rel h.hull).2.2.1 x x_in).2.1


variables (L : step_landscape E)

-- Cut-off function which needs to satisfies the next three lemmas
def ρ (L : step_landscape E) : E → ℝ :=
sorry

lemma ρ_smooth (L : step_landscape E) : 𝒞 ∞ L.ρ :=
sorry

lemma hρ₀ (L : step_landscape E) : ∀ᶠ x near L.K₀, L.ρ x = 1 :=
sorry

lemma hρ₁ (L : step_landscape E) : closure {x | L.ρ x ≠ 0} ⊆ L.K₁ :=
sorry

/--
Homotopy of formal solutions obtained by corrugation in the direction of `p : dual_pair' E`
in some landscape to improve a formal solution `𝓕` from being `L.E'`-holonomic to
`L.E' ⊔ span {p.v}`-holonomic near `L.K₀`.
-/
def improve_step (𝓕 : formal_sol R L.U) (N : ℝ) : htpy_jet_sec L.U F :=
if h : L.accepts R 𝓕
then
  { f := λ t, 𝓕.f +  corrugation L.π N (L.loop h t),
    f_diff := sorry,
    φ := λ t x , L.p.update (𝓕.φ x) (L.loop h (t*L.ρ x) x $ N * L.π x) +
                 (t*L.ρ x) • (corrugation.remainder L.p.π N (L.loop h 1) x),
    φ_diff := sorry }
else
  𝓕.to_jet_sec.const_htpy

/-
is_sol := begin
      intros t x x_in,
      rcases h with ⟨h, ε_pos⟩,
      have := L.loop_mem h x x_in (t*L.ρ x),
      have := step_landscape.mem_Ω (this $ L.N ⟨h, ε_pos⟩ * L.π x),
      dsimp only,
      by_cases h : x ∈ L.K₁,
      { rcases L.mem_of_c0_close _ with ⟨δ, δ_pos, hδ⟩,

        all_goals { sorry } },
      {
        sorry },

      all_goals { sorry },
    end
-/

variables (𝓕 : formal_sol R L.U) (N : ℝ)

lemma improve_step_rel_t_eq_0 : L.improve_step 𝓕 N 0 = 𝓕 :=
sorry

lemma improve_step_rel_C : ∀ᶠ x near L.C, ∀ t, L.improve_step 𝓕 N t x = 𝓕 x :=
sorry

lemma improve_step_rel_compl_K₁ : ∀ x ∉ L.K₁, ∀ t, L.improve_step 𝓕 N t x = 𝓕 x :=
sorry

lemma improve_step_c0_close {ε : ℝ} (ε_pos : 0 < ε) :
  ∀ᶠ N in at_top, ∀ x t, ∥L.improve_step 𝓕 N t x - 𝓕 x∥ ≤ ε :=
sorry

lemma improve_step_hol
  (h_op : R.is_open_over L.U)
  (h_part_hol : ∀ᶠ x near L.K₀, 𝓕.is_part_holonomic_at L.E' x)
  (h_short : ∀ x ∈ L.U, 𝓕.is_short_at L.p x)
  (h_hol : ∀ᶠ x near L.C, 𝓕.is_holonomic_at x) :
  ∀ N, ∀ᶠ x near L.K₀, (L.improve_step 𝓕 N 1).is_part_holonomic_at (L.E' ⊔ L.p.span_v) x :=
sorry

lemma improve_step_sol
  (h_op : R.is_open_over L.U)
  (h_part_hol : ∀ᶠ x near L.K₀, 𝓕.is_part_holonomic_at L.E' x)
  (h_short : ∀ x ∈ L.U, 𝓕.is_short_at L.p x)
  (h_hol : ∀ᶠ x near L.C, 𝓕.is_holonomic_at x) :
  ∀ᶠ N in at_top, (L.improve_step 𝓕 N 1).is_formal_sol R :=
sorry


end step_landscape

end improve_step

lemma finite_dimensional.fin_succ_basis (K V : Type*) [division_ring K] [add_comm_group V] [module K V]
  [finite_dimensional K V] [nontrivial V] : ∃ (n : ℕ), nonempty (basis (fin (n + 1)) K V) :=
sorry

section improve
/-!
## Full improvement

This section proves lem:h_principle_open_ample_loc.
-/

open finite_dimensional submodule

variables {E}

/--
Homotopy of formal solutions obtained by successive corrugations in some landscape `L` to improve a
formal solution `𝓕` until it becomes holonomic near `L.K₀`.
-/
lemma rel_loc.formal_sol.improve {R : rel_loc E F} {L : landscape E} {𝓕 : formal_sol R L.U} {ε : ℝ}
(ε_pos : 0 < ε) (h_op : R.is_open_over L.U) (h_ample : R.is_ample)
(h_hol :∀ᶠ x near L.C, 𝓕.is_holonomic_at x) : ∃ H : htpy_jet_sec L.U F,
 (H 0 = 𝓕) ∧
 (∀ᶠ x near L.C, ∀ t, H t x = 𝓕 x ) ∧
 (∀ x, x ∉ L.K₁ → ∀ t, H t x = 𝓕 x) ∧
 (∀ x t, ∥H t x - 𝓕 x∥ ≤ ε) ∧
 (∀ t, (H t).is_formal_sol R) ∧
 (∀ᶠ x near L.K₀, (H 1).is_holonomic_at x) :=
begin
  by_cases hE : nontrivial E,
  { haveI := hE,
    rcases fin_succ_basis ℝ E with ⟨n, ⟨e⟩⟩,

    let E' : fin (n+1) → submodule ℝ E := λ k, span ℝ $ e '' {j : fin (n+1) | j < k},
    suffices : ∀ k : fin (n + 1), ∃ H : htpy_jet_sec L.U F,
      (H 0 = 𝓕) ∧
      (∀ᶠ x near L.C, ∀ t, H t x = 𝓕 x ) ∧
      (∀ x, x ∉ L.K₁ → ∀ t, H t x = 𝓕 x) ∧
      (∀ x t, ∥H t x - 𝓕 x∥ ≤ ε) ∧
      (∀ t, (H t).is_formal_sol R) ∧
      (∀ᶠ x near L.K₀, (H 1).is_part_holonomic_at (E' k) x),
    sorry ; { have eq_top : E' (fin.last n) = ⊤,
      {
        sorry },
      have key := this (fin.last n),
      rw [eq_top] at key,
      simp_rw is_part_holonomic_top at key,
      exact key },
    intro k,
    apply fin.induction_on k ; clear k,
    { use 𝓕.to_jet_sec.const_htpy,
      have eq_bot : E' 0 = ⊥,
      {
        sorry },
      sorry ; simp [eq_bot, ε_pos.le] },
    { rintros k ⟨H, hH₀, hHC, hHK₁, hHc0, hH_sol, hH_hol⟩,
      let S : step_landscape E :=
      { E' := E' k,
        p := e.dual_pair' k,
        hEp := sorry,
        ..L},
      set H₁ : formal_sol R L.U := (hH_sol 1).formal_sol,
      have h_span : S.E' ⊔ S.p.span_v = E' k.succ,
      {
        sorry },
      have acc : S.accepts R H₁ :=
      { h_op := sorry,
        hK₀ := sorry,
        h_short := sorry,
        hC := sorry  },
      let N : ℝ := _,
      refine ⟨H.comp (S.improve_step H₁ N), _, _, _, _, _, _⟩,
      sorry;{ simp [hH₀] }, -- t = 0
      { -- rel C
        sorry },
      { -- rel K₁
        sorry },
      { -- C⁰-close
        sorry },
      { -- formal solution

        sorry },
      {  -- part-hol E' (k + 1)
        rw [← h_span, htpy_jet_sec.comp_1],
        apply S.improve_step_hol H₁ h_op,
        sorry ; { -- part-hol E'
          simpa only [← fin.coe_eq_cast_succ] using hH_hol },
        { -- short  Needs the lemma that ample implies short
          sorry },
        sorry ; { -- hol near C
          apply h_hol.congr (formal_sol.is_holonomic_at_congr _ _ _),
          apply hHC.mono (λ x hx, (hx 1).symm) } },
      sorry -- def N
      } },
  {
    sorry },
end


end improve
