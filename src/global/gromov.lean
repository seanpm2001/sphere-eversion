import to_mathlib.data.set.prod
import to_mathlib.data.nat.basic
import local.h_principle
import global.parametricity_for_free
import global.localized_construction
import global.localisation_data

import interactive_expr

/-!
# Gromov's theorem

We prove the h-principle for open and ample first order differential relations.
-/

noncomputable theory

open set filter model_with_corners metric
open_locale topological_space manifold

variables
{EM : Type*} [normed_add_comm_group EM] [normed_space ℝ EM] [finite_dimensional ℝ EM]
{HM : Type*} [topological_space HM] {IM : model_with_corners ℝ EM HM} [boundaryless IM]
{M : Type*} [topological_space M] [charted_space HM M] [smooth_manifold_with_corners IM M]
[t2_space M]
[locally_compact_space M] -- FIXME: investigate how to deduce this from finite-dimensional
[nonempty M] -- FIXME: investigate how to remove this
[sigma_compact_space M]

{EX : Type*} [normed_add_comm_group EX] [normed_space ℝ EX] [finite_dimensional ℝ EX]
{HX : Type*} [topological_space HX] {IX : model_with_corners ℝ EX HX} [model_with_corners.boundaryless IX]
-- note: X is a metric space
{X : Type*} [metric_space X] [charted_space HX X] [smooth_manifold_with_corners IX X]
[locally_compact_space X] -- FIXME: investigate how to deduce this from finite-dimensional
[sigma_compact_space X]
[nonempty X] -- FIXME: investigate how to remove this

{R : rel_mfld IM M IX X}
{A : set M} {δ : M → ℝ}

set_option trace.filter_inst_type true

lemma rel_mfld.ample.satisfies_h_principle_core
  (hRample : R.ample) (hRopen : is_open R)
  (hA : is_closed A)
  (hδ_pos : ∀ (x : M), 0 < δ x)
  (hδ_cont : continuous δ)
  (F₀ : formal_sol R)
  (hF₀A : ∀ᶠ x near A, F₀.is_holonomic_at x)
  (L : localisation_data IM IX F₀.bs) :
  ∃ F : ℕ → htpy_formal_sol R, ∀ n : ℕ,
    ((F n 0 = F₀) ∧
    (∀ t, ∀ᶠ x near A, F n t x = F₀ x) ∧
    (∀ t x, dist ((F n t).bs x) (F₀.bs x) < δ x) ∧

    (∀ᶠ x near ⋃ i ≤ L.index n, (L.φ i) '' metric.closed_ball 0 1,
      ((F n) 1).to_one_jet_sec.is_holonomic_at x)) ∧
    ((L.index (n + 1)  = L.index n → F (n + 1) = F n) ∧
     ∀ t (x ∉ range (L.φ $ L.index $ n+1)), F (n + 1) t x = F n t x) :=
begin
  classical,
  borelize EX,
  let P : ℕ → htpy_formal_sol R → Prop := λ n Fn,
    (Fn 0 = F₀) ∧
    (∀ t, ∀ᶠ x near A, Fn t x = F₀ x) ∧
    (∀ t x, dist ((Fn t).bs x) (F₀.bs x) < δ x) ∧
    (∀ t x, dist ((Fn t).bs x) (F₀.bs x) < L.ε x) ∧
    (∀ᶠ x near ⋃ i ≤ L.index n, (L.φ i) '' metric.closed_ball 0 1,
      (Fn 1).is_holonomic_at x),
  let Q : ℕ → htpy_formal_sol R → htpy_formal_sol R → Prop := λ n Fn Fnp1,
    (L.index (n + 1)  = L.index n → Fnp1 = Fn) ∧
     ∀ t, ∀ x ∉ range (L.φ $ L.index $ n+1), Fnp1 t x = Fn t x,
  suffices : ∃ F : ℕ → htpy_formal_sol R, ∀ n, P n (F n) ∧ Q n (F n) (F $ n+1),
  { rcases this with ⟨F, hF⟩,
    use F,
    intro n,
    cases hF n,
    tauto },
  let K₀ : set EM := closed_ball 0 1,
  have hK₀ : is_compact K₀, from is_compact_closed_ball 0 1,
  let K₁ : set EM := closed_ball 0 2,
  have hK₁ : is_compact K₁, from is_compact_closed_ball 0 2,
  have hK₀K₁ : K₀ ⊆ interior K₁,
  { dsimp [K₀, K₁],
    rw interior_closed_ball (0 : EM) (by norm_num : (2 : ℝ) ≠ 0),
    exact closed_ball_subset_ball (by norm_num) },
  let τ := λ x : M, min (δ x) (L.ε x),
  have τ_pos : ∀ x, 0 < τ x, from λ x, lt_min (hδ_pos x) (L.ε_pos x),
  have τ_cont : continuous τ, from hδ_cont.min L.ε_cont,
  apply exists_by_induction' P Q,
  { dsimp only [P], clear P Q,
    let F := F₀.const_htpy,
    have hF₀A : ∀ᶠ x near A, (F 0).is_holonomic_at x,
    { simp only [F₀.const_htpy_eq, hF₀A] },
    have hFF₀τ : ∀ t x, dist ((F t).bs x) ((F 0).bs x) < τ x,
    { simp only [F₀.const_htpy_eq, dist_self, τ_pos, forall_const] },
    have hFφψ : ∀ t, (F t).bs '' (range $ L.φ 0) ⊆ range (L.ψj 0),
    { simp only [F₀.const_htpy_eq, forall_const, ← range_comp, L.rg_subset_rg] },
    have hFA : ∀ t, ∀ᶠ x near A, F t x = F 0 x,
    { simp only [F₀.const_htpy_eq, eq_self_iff_true, eventually_true, forall_const] },
    have hFC : ∀ᶠ x near ∅, (F 1).is_holonomic_at x,
    { simp only [nhds_set_empty] },
    rcases (L.φ 0).improve_htpy_formal_sol (L.ψj 0) hRample hRopen hA is_closed_empty
      τ_pos τ_cont hF₀A hFF₀τ hFφψ hFA hFC hK₀ hK₁ hK₀K₁ with ⟨F', hF'₀, hF'A, hF'F₀τ, hF'K₁, hF'τ, hF'K₀⟩,
    refine ⟨F', _, hF'A, _, _, _⟩,
    { rw [hF'₀, F₀.const_htpy_eq] },
    { exact λ t x, lt_of_lt_of_le (hF'τ t x) (min_le_left _ _) },
    { exact λ t x, lt_of_lt_of_le (hF'τ t x) (min_le_right _ _) },
    { intros x hx,
      rw L.Union_le_zero at hx,
      exact  hF'K₀.filter_mono (nhds_set_mono $ subset_union_right _ _) hx } },
  { rintros n F ⟨hF₀, hFA, hFδ, hFε, hFhol⟩,
    by_cases hn : L.index (n+1) = L.index n,
    { refine ⟨F, ⟨hF₀, hFA, hFδ, hFε, _⟩, λ _, rfl, λ _ _ _, rfl⟩ ; clear P Q,
      rw hn,
      exact hFhol },
    { dsimp only [P, Q], clear P Q,
      simp only [← hF₀] at hF₀A hFδ hFε hFA ⊢,
      have hFτ : ∀ t x, dist ((F t).bs x) ((F 0).bs x) <  τ x,
      { exact λ t x, lt_min (hFδ t x) (hFε t x) },
      rcases (L.φ $ L.index $ n+1).improve_htpy_formal_sol (L.ψj $ L.index $ n+1) hRample hRopen
        hA _ τ_pos τ_cont hF₀A hFτ _ hFA hFhol hK₀ hK₁ hK₀K₁  with
        ⟨F', hF'₀, hF'A, hF'F, hF'K₁, hF'τ, hF'K₀⟩,
      refine ⟨F', ⟨hF'₀, _, _, _, _⟩, _, _⟩ ; clear hRample hRopen hδ_pos hδ_cont hK₀ hK₁ hK₀K₁,
      { exact hF'A },
      { exact λ t x, lt_of_lt_of_le (hF'τ t x) (min_le_left _ _) },
      { exact λ t x, lt_of_lt_of_le (hF'τ t x) (min_le_right _ _) },
      { rw L.Union_succ,
        have : ∀ᶠ x near ⋃ i ≤ L.index n, (L.φ i) '' K₀, (F' 1).is_holonomic_at x,
        { apply ((hF'F 1).eventually_nhds_set.and hFhol).mono,
          rintros x ⟨hx, hx'⟩,
          exact hx'.congr (eventually_eq.symm hx) },
        replace hF'K₀ : ∀ᶠ x near (L.φ (L.index (n + 1))) '' K₀, (F' 1).is_holonomic_at x,
          from hF'K₀.filter_mono (nhds_set_mono $ subset_union_right _ _),
        exact this.union hF'K₀ },
      { exact λ hn', (hn hn').elim },
      { exact λ t x hx, hF'K₁ t x (λ hx', hx $ mem_range_of_mem_image _ _ hx') },
      { exact L.is_closed_Union hK₀ n },
      { intro t,
        rw ← range_comp,
        apply L.ε_spec,
        simp only [← hF₀],
        apply hFε } } },
end

/-- The non-parametric version of Gromov's theorem -/
lemma rel_mfld.ample.satisfies_h_principle (hRample : R.ample) (hRopen : is_open R)
  (hA : is_closed A)
  (hδ_pos : ∀ x, 0 < δ x) (hδ_cont : continuous δ) :
  R.satisfies_h_principle A δ :=
begin
  refine rel_mfld.satisfies_h_principle_of_weak hA _,
  unfreezingI { clear_dependent A },
  intros A hA 𝓕₀ h𝓕₀,
  have cont : continuous 𝓕₀.bs, from 𝓕₀.smooth_bs.continuous,
  let L : localisation_data IM IX 𝓕₀.bs := std_localisation_data EM IM EX IX cont,
  let π := L.index,

  suffices : ∃ F : ℕ → htpy_formal_sol R, ∀ n,
    ((F n 0 = 𝓕₀) ∧
    (∀ t, ∀ᶠ x near A, F n t x = 𝓕₀ x) ∧
    (∀ t x, dist ((F n t).bs x) (𝓕₀.bs x) < δ x) ∧

    (∀ x ∈ ⋃ i ≤ π n, L.φ i '' metric.closed_ball (0 : EM) 1,
             (F n 1).is_holonomic_at x)) ∧
    ((π (n+1) = π n → F (n+1) = F n) ∧
     (∀ t, ∀ x ∉ range (L.φ $ π (n+1)), F (n+1) t x = F n t x)),
  { clear_dependent hRample hRopen,
    simp_rw [and_assoc, forall_and_distrib] at this,
    rcases this with ⟨F, hF₀, hfA, hFδ, hFhol, hFπ, hFultim⟩,
    let FF := λ n : ℕ, λ p : ℝ × M, F n p.1 p.2,
    have h : ∀ n : ℕ, ∀ x ∉ (univ : set ℝ) ×ˢ range (L.φ $ π $ n+1), FF (n+1) x = FF n x,
    { rintros n ⟨t, x⟩ H,
      exact hFultim _ _ _ (λ hx, H ⟨trivial, hx⟩) },
    have h' : ∀ (n : ℕ), π (n + 1) = π n → FF (n + 1) = FF n,
    { intros n hn,
      ext1 ⟨t, x⟩,
      dsimp [FF],
      rw hFπ n hn },
    have loc_fin : locally_finite (λ i, (univ ×ˢ range (L.φ i) : set $ ℝ × M)),
    { rintros ⟨t, x⟩,
      rcases L.lf_φ x with ⟨s, s_in, hs⟩,
      refine ⟨univ ×ˢ s, _, _⟩,
      { rw nhds_prod_eq,
        exact filter.prod_mem_prod filter.univ_mem s_in },
      { convert hs,
        ext i,
        simp [univ_prod_inter_univ_prod] } },
    have : ∀ x : ℝ × M, ∀ᶠ n in at_top, x.2 ∈ ⋃ i ≤ π n, (L.φ i) '' metric.ball 0 1,
    { rintros ⟨t, x⟩,
      rw [eventually_at_top],
      rcases (mem_top.mpr L.h₁ x) with ⟨-, ⟨i, rfl⟩, hi : x ∈ (L.φ i) '' metric.ball 0 1⟩,
      refine ⟨indexing.to_nat i, λ n hn, _⟩,
      have : i ≤ π n,
      { rw ← indexing.from_to i,
        exact indexing.mono_from hn },
      exact mem_bUnion this hi },
    cases loc_fin.exists_forall_eventually_of_indexing h h' with G hG, clear h h' loc_fin,
    choose n hn' hn using λ x, eventually_at_top.mp ((this x).and (hG x)), clear hG this,
    have G_eq : ∀ t x, G (t, x) = F (n (t, x)) t x,
    { exact λ t x, ((hn (t, x) _ le_rfl).eq_of_nhds).symm },
    have hG11 : ∀ t x, (G (t, x)).1.1 = x,
    { intros t x,
      rw G_eq,
      refl },
    let 𝓕 : htpy_formal_sol R := {
      bs := λ t x, (G (t, x)).1.2,
      ϕ := λ t x, (G (t, x)).2,
      smooth' := begin
        intro x,
        apply ((F (n x)).smooth' x).congr_of_eventually_eq,
        apply (hn x _ le_rfl).mono,
        intros p hp,
        dsimp only,
        rw [show (p.1, p.2) = p, from prod.ext rfl rfl, ← hp],
        refl
      end,
      is_sol' := begin
        intros t x,
        change one_jet_bundle.mk x (G (t, x)).1.2 (G (t, x)).2 ∈ R,
        rw ← (hn (t, x) _ le_rfl).eq_of_nhds,
        exact (F (n (t, x))).is_sol' t x,
      end },
    refine ⟨𝓕, _, _, _, _⟩,
    { clear_dependent δ hfA hFhol hFπ hFultim,
      intro x,
      ext,
      { refl },
      { change (G (0, x)).1.2 = _,
        rw [G_eq, hF₀] },
      { apply heq_of_eq,
        change (G (0, x)).2 = _,
        rw [G_eq, hF₀] } },
    { clear_dependent δ hF₀ hfA hFπ hFultim,
      intro x,
      have : x ∈ ⋃ i ≤ π (n (1, x)), (L.φ i) '' metric.closed_ball 0 1,
      { have : x ∈ _ := hn' (1, x) _ le_rfl,
        apply set.bUnion_mono subset_rfl _ this,
        rintros i -,
        exact image_subset _ metric.ball_subset_closed_ball, },
      apply (hFhol (n (1, x)) x this).congr, clear this,
      have : F (n (1, x)) 1 =ᶠ[𝓝 x] (λ x, G (1, x)),
      { exact (hn (1, x) (n(1, x)) le_rfl).slice },
      apply this.mono, clear this,
      rintros y (hy : F (n (1, x)) 1 y = G (1, y)),
      change F (n (1, x)) 1 y = 𝓕 1 y,
      rw hy,
      change G (1, y) = 𝓕 1 y,
      ext ; try { refl },
      rw hG11,
      refl },
    { clear_dependent δ hF₀ hFhol hFπ hFultim,
      intros x x_in t,
      rw [← (hfA (n (t, x)) t).nhds_set_forall_mem x x_in, ← G_eq],
      ext ; try { refl },
      rw hG11, refl, },
    { clear_dependent hF₀ hFhol hFπ hFultim hfA,
      intros t x,
      apply le_of_lt,
      change dist (G (t, x)).1.2 (𝓕₀.bs x) < δ x,
      rw ← (hn (t, x) _ le_rfl).eq_of_nhds,
      exact hFδ (n (t, x)) t x } },
  -- The next six lines work around the fact that the statement of `satisfies_h_principle_core`
  -- is now slightly too strong. This should be aligned at some point.
  rcases hRample.satisfies_h_principle_core hRopen hA hδ_pos hδ_cont 𝓕₀ h𝓕₀ L with ⟨F, h⟩,
  refine ⟨F, λ n, _⟩,
  rcases h n with ⟨⟨h₀, h₁, h₂, h₃⟩, h₄, h₅⟩,
  refine ⟨⟨_, _, _, _⟩, _, _⟩,
  all_goals { try { assumption} },
  exact h₃.on_set
end

variables
{EP : Type*} [normed_add_comm_group EP] [normed_space ℝ EP]  [finite_dimensional ℝ EP]
{HP : Type*} [topological_space HP] {IP : model_with_corners ℝ EP HP} [model_with_corners.boundaryless IP]
{P : Type*} [topological_space P] [charted_space HP P] [smooth_manifold_with_corners IP P]
[locally_compact_space P] -- investigate how to deduce this from finite-dimensional
[sigma_compact_space P]
[t2_space P]
[nonempty P] -- investigate how to remove this
{C : set (P × M)}

/-- **Gromov's Theorem** -/
theorem rel_mfld.ample.satisfies_h_principle_with (hRample : R.ample) (hRopen : is_open R)
  (hC : is_closed C)
  (hδ_pos : ∀ x, 0 < δ x) (hδ_cont : continuous δ) :
  R.satisfies_h_principle_with IP C δ :=
begin
  have hδ_pos' : ∀ (x : P × M), 0 < δ x.2 := λ (x : P × M), hδ_pos x.snd,
  have hδ_cont' : continuous (λ (x : P × M), δ x.2) := hδ_cont.comp continuous_snd,
  have is_op : is_open (rel_mfld.relativize IP P R) := R.is_open_relativize hRopen,
  apply rel_mfld.satisfies_h_principle.satisfies_h_principle_with,
  exact (hRample.relativize IP P).satisfies_h_principle is_op hC hδ_pos' hδ_cont',
end

variables
{E' : Type*} [normed_add_comm_group E'] [normed_space ℝ E'] [finite_dimensional ℝ E']
{H' : Type*} [topological_space H'] {I' : model_with_corners ℝ E' H'} [model_with_corners.boundaryless I']
{M' : Type*} [topological_space M'] [charted_space H' M'] [smooth_manifold_with_corners I' M']
[locally_compact_space M'] -- investigate how to deduce this from finite-dimensional
[sigma_compact_space M']
[t2_space M']
[nonempty M'] -- investigate how to remove this

include IP

/-- Gromov's Theorem without metric space assumption -/
theorem rel_mfld.ample.satisfies_h_principle_with' {R : rel_mfld IM M I' M'}
  (hRample : R.ample) (hRopen : is_open R) (hC : is_closed C)
  (hδ_pos : ∀ x, 0 < δ x) (hδ_cont : continuous δ) :
  by letI := (@topological_space.metrizable_space_metric _ _
    (manifold_with_corners.metrizable_space I' M')); exact
  R.satisfies_h_principle_with IP C δ :=
begin
  haveI := (@topological_space.metrizable_space_metric _ _
    (manifold_with_corners.metrizable_space I' M')),
  apply rel_mfld.ample.satisfies_h_principle_with; assumption
end
