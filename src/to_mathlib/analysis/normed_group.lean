import analysis.normed.group.basic

lemma norm_sub_le_add {G : Type*} [normed_add_comm_group G] (a b c : G) : ‖a - b‖ ≤ ‖a - c‖ + ‖c - b‖ :=
by simp [← dist_eq_norm, ← dist_eq_norm, ← dist_eq_norm, dist_triangle]

lemma norm_sub_le_add_of_le {G : Type*} [normed_add_comm_group G] {a b c : G} {d d' : ℝ}
  (h : ‖a - c‖ ≤ d) (h' : ‖c - b‖ ≤ d') : ‖a - b‖ ≤ d + d' :=
(norm_sub_le_add a b c).trans $ add_le_add h h'
