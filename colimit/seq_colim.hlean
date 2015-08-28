/-
Copyright (c) 2015 Floris van Doorn. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Floris van Doorn, Egbert Rijke
-/
import hit.quotient .sequence cubical.squareover types.arrow

open eq nat sigma sigma.ops quotient equiv equiv.ops pi is_trunc is_equiv

namespace seq_colim

  section
  parameters (A : ℕ → Type) [f : seq_diagram A]
  variables {n : ℕ} (a : A n)
  include f

  local abbreviation B := Σ(n : ℕ), A n
  inductive seq_rel : B → B → Type :=
  | Rmk : Π{n : ℕ} (a : A n), seq_rel ⟨succ n, f a⟩ ⟨n, a⟩
  open seq_rel
  local abbreviation R := seq_rel

  definition seq_colim : Type :=
  quotient seq_rel

  parameters {A f}
  definition inclusion : seq_colim :=
  class_of R ⟨n, a⟩

  abbreviation ι := @inclusion

  definition glue : ι (f a) = ι a :=
  eq_of_rel seq_rel (Rmk a)

  protected definition rec {P : seq_colim → Type}
    (Pincl : Π⦃n : ℕ⦄ (a : A n), P (ι a))
    (Pglue : Π(n : ℕ) (a : A n), Pincl (f a) =[glue a] Pincl a) (aa : seq_colim) : P aa :=
  begin
    fapply (quotient.rec_on aa),
    { intro a, cases a, apply Pincl},
    { intro a a' H, cases H, apply Pglue}
  end

  protected definition rec_on [reducible] {P : seq_colim → Type} (aa : seq_colim)
    (Pincl : Π⦃n : ℕ⦄ (a : A n), P (ι a))
    (Pglue : Π⦃n : ℕ⦄ (a : A n), Pincl (f a) =[glue a] Pincl a)
      : P aa :=
  rec Pincl Pglue aa

  theorem rec_glue {P : seq_colim → Type} (Pincl : Π⦃n : ℕ⦄ (a : A n), P (ι a))
    (Pglue : Π⦃n : ℕ⦄ (a : A n), Pincl (f a) =[glue a] Pincl a) {n : ℕ} (a : A n)
      : apdo (rec Pincl Pglue) (glue a) = Pglue a :=
  !rec_eq_of_rel

  protected definition elim {P : Type} (Pincl : Π⦃n : ℕ⦄ (a : A n), P)
    (Pglue : Π⦃n : ℕ⦄ (a : A n), Pincl (f a) = Pincl a) : seq_colim → P :=
  rec Pincl (λn a, pathover_of_eq (Pglue a))

  protected definition elim_on [reducible] {P : Type} (aa : seq_colim)
    (Pincl : Π⦃n : ℕ⦄ (a : A n), P)
    (Pglue : Π⦃n : ℕ⦄ (a : A n), Pincl (f a) = Pincl a) : P :=
  elim Pincl Pglue aa

  theorem elim_glue {P : Type} (Pincl : Π⦃n : ℕ⦄ (a : A n), P)
    (Pglue : Π⦃n : ℕ⦄ (a : A n), Pincl (f a) = Pincl a) {n : ℕ} (a : A n)
      : ap (elim Pincl Pglue) (glue a) = Pglue a :=
  begin
    apply eq_of_fn_eq_fn_inv !(pathover_constant (glue a)),
    rewrite [▸*,-apdo_eq_pathover_of_eq_ap,↑elim,rec_glue],
  end

  protected definition elim_type (Pincl : Π⦃n : ℕ⦄ (a : A n), Type)
    (Pglue : Π⦃n : ℕ⦄ (a : A n), Pincl (f a) ≃ Pincl a) : seq_colim → Type :=
  elim Pincl (λn a, ua (Pglue a))

  protected definition elim_type_on [reducible] (aa : seq_colim)
    (Pincl : Π⦃n : ℕ⦄ (a : A n), Type)
    (Pglue : Π⦃n : ℕ⦄ (a : A n), Pincl (f a) ≃ Pincl a) : Type :=
  elim_type Pincl Pglue aa

  theorem elim_type_glue (Pincl : Π⦃n : ℕ⦄ (a : A n), Type)
    (Pglue : Π⦃n : ℕ⦄ (a : A n), Pincl (f a) ≃ Pincl a) {n : ℕ} (a : A n)
      : transport (elim_type Pincl Pglue) (glue a) = Pglue a :=
  by rewrite [tr_eq_cast_ap_fn,↑elim_type,elim_glue];apply cast_ua_fn

end
end seq_colim

attribute seq_colim.inclusion seq_colim.ι [constructor]
attribute seq_colim.rec seq_colim.elim [unfold 6] [recursor 6]
attribute seq_colim.elim_type [unfold 5]
attribute seq_colim.rec_on seq_colim.elim_on [unfold 4]
attribute seq_colim.elim_type_on [unfold 3]

namespace seq_colim

  variables {A : ℕ → Type} [f : seq_diagram A]
  variables {n : ℕ} (a : A n)
  include f

  variable {A}
  definition shift_up (a : seq_colim A) : seq_colim (λk, A (succ k)) :=
  begin
    induction a,
    { induction n with n IH,
        exact ι (f a),
        clear IH, exact ι a},
    { induction n with n IH,
        reflexivity,
        clear IH, esimp, exact glue a}
  end

  definition shift_down (a : seq_colim (λn, A (succ n))) : seq_colim A :=
  begin
    induction a,
    { exact ι a},
    { exact glue a}
  end

  -- definition kshift_up (k : ℕ) (a : seq_colim A) : seq_colim (λn, A (k + n)) :=
  -- begin
  --   induction a,
  --   { },
  --   { }
  -- end

  -- definition kshift_down (k : ℕ) (a : seq_colim (λn, A (k + n))) : seq_colim A :=
  -- begin
  --   induction a,
  --   { exact ι a},
  --   { exact glue a}
  -- end

  variable (A)
  definition shift_equiv [constructor] : seq_colim A ≃ seq_colim (λn, A (succ n)) :=
  equiv.MK shift_up
           shift_down
           begin
             intro a, induction a,
             { reflexivity},
             { apply eq_pathover, apply hdeg_square,
               rewrite [ap_id,ap_compose shift_up shift_down,↑shift_down,
                        @elim_glue (λk, A (succ k)) _],
               apply elim_glue}
           end
           begin
             intro a, induction a,
             { induction n with n IH,
               { esimp [shift_up,shift_down], exact glue a},
               { clear IH, reflexivity}},
             { induction n with n IH,
               { esimp, apply eq_pathover, apply square_of_eq,
                 rewrite [ap_id,ap_compose shift_down shift_up,↑shift_up,@elim_glue A _,▸*]},
               { clear IH, esimp, apply eq_pathover, apply square_of_eq,
                 rewrite [ap_id,ap_compose shift_down shift_up,↑shift_up,
                          @elim_glue A _,↑[shift_down],idp_con],
                 symmetry, apply elim_glue}},
           end

  variable {A}

  /- functorial action and equivalences -/
  section functor
  variables {A' : ℕ → Type} [f' : seq_diagram A']
  variables (g : Π{n}, A n → A' n) (p : Π⦃n⦄ (a : A n), g (f a) = f' (g a))
  include p

  definition seq_colim_functor [unfold 7] : seq_colim A → seq_colim A' :=
  seq_colim.elim (λn a, ι (g a)) (λn a, ap ι (p a) ⬝ glue (g a))

  theorem seq_colim_functor_glue {n : ℕ} (a : A n)
    : ap (seq_colim_functor @g p) (glue a) = ap ι (p a) ⬝ glue (g a) :=
  !elim_glue

  omit p f

  definition inv_commute'_fn {A : Type} {B C : A → Type} (f : Π{a}, B a → C a)
    [H : Πa, is_equiv (@f a)]
    {g : A → A} (h : Π{a}, B a → B (g a)) (h' : Π{a}, C a → C (g a))
    (p : Π⦃a : A⦄ (b : B a), f (h b) = h' (f b)) {a : A} (b : B a) :
    inv_commute' @f @h @h' p (f b)
      = (ap f⁻¹ (p b))⁻¹ ⬝ left_inv f (h b) ⬝ (ap h (left_inv f b))⁻¹ :=
  begin
    rewrite [↑[inv_commute',eq_of_fn_eq_fn'],+ap_con,-adj_inv f,+con.assoc,inv_con_cancel_left,
             adj f,+ap_inv,-+ap_compose],
    check_expr (natural_square (λb, (left_inv f (h b))⁻¹ ⬝ ap f⁻¹ (p b)) (left_inv f b))⁻¹ʰ,
    let H := (natural_square (λb, (left_inv f (h b))⁻¹ ⬝ ap f⁻¹ (p b)) (left_inv f b))⁻¹ʰ,
    exact sorry
  end

  include f p
  --set_option pp.notation false
  definition is_equiv_seq_colim_functor [H : Πn, is_equiv (g : A n → A' n)]
     : is_equiv (seq_colim_functor @g p) :=
  adjointify _ (seq_colim_functor (λn, g⁻¹) (λn a, inv_commute' @g @f @f' p a))
             begin
               intro x, induction x,
               { esimp, exact ap ι (right_inv g a)},
               { apply eq_pathover,
                 rewrite [ap_id,ap_compose (seq_colim_functor @g p) (seq_colim_functor _ _),
                   seq_colim_functor_glue _ _ a,ap_con,▸*,seq_colim_functor_glue _ _ (g⁻¹ a),
                   -ap_compose,↑[function.compose],ap_compose ι g,ap_inv_commute',+ap_con,con.assoc,
                   +ap_inv,inv_con_cancel_left,con.assoc,-ap_compose],
                 apply whisker_tl, apply move_left_of_top, esimp,
                 apply transpose, apply square_of_pathover, apply apdo}
             end
             begin
               intro x, induction x,
               { esimp, exact ap ι (left_inv g a)},
               { apply eq_pathover,
                 rewrite [ap_id,ap_compose (seq_colim_functor _ _) (seq_colim_functor _ _),
                   seq_colim_functor_glue _ _ a,ap_con,▸*,seq_colim_functor_glue _ _ (g a),
                   -ap_compose,↑[function.compose],ap_compose ι g⁻¹,inv_commute'_fn,+ap_con,
                   con.assoc,con.assoc,+ap_inv,con_inv_cancel_left,-ap_compose],
                 apply whisker_tl, apply move_left_of_top, esimp,
                 apply transpose, apply square_of_pathover, apply apdo}
             end

  definition seq_colim_equiv (g : Π{n}, A n ≃ A' n)
    (p : Π⦃n⦄ (a : A n), g (f a) = f' (g a)) : seq_colim A ≃ seq_colim A' :=
  equiv.mk _ (is_equiv_seq_colim_functor @g p)

  omit p
  definition seq_colim_rec_unc [unfold 4] {P : seq_colim A → Type}
    (v : Σ(Pincl : Π ⦃n : ℕ⦄ (a : A n), P (ι a)),
                   Π ⦃n : ℕ⦄ (a : A n), Pincl (f a) =[ glue a ] Pincl a)
    : Π(x : seq_colim A), P x :=
  by induction v with Pincl Pglue ;exact seq_colim.rec Pincl Pglue

  omit f
  --set_option pp.notation false
  definition eq_pathover_dep {A : Type} {B : A → Type} {a a' : A}
    {f g : Πa, B a} {p : a = a'} {q : f a = g a} {r : f a' = g a'}
    (s : squareover B !hrfl (pathover_idp_of_eq q) (pathover_idp_of_eq r) (apdo f p) (apdo g p))
      : q =[p] r :=
  begin
    induction p, apply pathover_idp_of_eq,
    let H  := pathover_of_vdeg_squareover s,
    let H' := eq_of_pathover_idp H,
    exact eq_of_fn_eq_fn !pathover_idp⁻¹ᵉ H',
  end
  include f

  definition is_equiv_seq_colim_rec (P : seq_colim A → Type) :
    is_equiv (seq_colim_rec_unc :
      (Σ(Pincl : Π ⦃n : ℕ⦄ (a : A n), P (ι a)),
        Π ⦃n : ℕ⦄ (a : A n), Pincl (f a) =[ glue a ] Pincl a)
          → (Π (aa : seq_colim A), P aa)) :=
  begin
    fapply adjointify,
    { intro f, exact ⟨λn a, f (ι a), λn a, apdo f (glue a)⟩},
    { intro f, apply eq_of_homotopy, intro x, induction x,
      { reflexivity},
      { apply eq_pathover_dep, esimp, apply hdeg_squareover, apply rec_glue}},
    { intro v, induction v with Pincl Pglue, fapply ap (sigma.mk _),
      apply eq_of_homotopy2, intros n a, apply rec_glue},
  end

  end functor

  /- colimits of dependent sequences, sigma's commute with colimits -/

  section over

  universe variable v
  variables (P : Π⦃n⦄, A n → Type.{v}) [g : seq_diagram_over P]
  include g

  theorem f_rep_equiv_rep_f
    : seq_colim (λk, P (rep (succ k) a)) ≃
    @seq_colim (λk, P (rep k (f a))) (seq_diagram_of_over P (f a)) :=
  sorry
  -- begin
  --   fapply equiv.MK,
  --   { intro x, induction x with k b k b,
  --     { apply ι, exact (rep_f k a)⁻¹ᵒ ▸o b},
  --     { let H := @glue (λk, P (rep (succ k) a)) _ _ b,
  --       exact sorry}},
  --   { intro x, induction x with k b k b,
  --     { apply ι, exact rep_f k a ▸o b},
  --     { exact sorry}}, -- unfold rep_f fails
  --   { intro x, induction x with k b k b,
  --        esimp, exact sorry,
  --        exact sorry},
  --   { intro x, induction x with k b k b,
  --        esimp, exact sorry,
  --        exact sorry},
  -- end

  -- alternative proof using induction on k
  -- theorem f_rep_equiv_rep_f'
  --   : seq_colim (λk, P (rep (succ k) a)) ≃
  --   @seq_colim (λk, P (rep k (f a))) (seq_diagram_of_over P (f a)) :=
  -- begin
  --   fapply equiv.MK,
  --   { intro x, induction x with k b k b,
  --     { revert a b, induction k with k IH, all_goals intro a b,
  --         apply ι, change (P (rep 0 (f a))), exact b,
  --         apply ι, change (P (rep (succ k) (f a))), exact sorry},
  --     { exact sorry}},
  --   { intro x, induction x with k b k b,
  --       apply ι, exact rep_f k a ▸o b,
  --       exact sorry},
  --   { intro x, induction x with k b k b,
  --        esimp, exact sorry,
  --        exact sorry},
  --   { intro x, induction x with k b k b,
  --        esimp, exact sorry,
  --        exact sorry},
  -- end

  -- theorem rep_rep_equiv (l : ℕ)
  --   : @seq_colim (λk, P (rep (succ k) a)) _ ≃
  --   @seq_colim (λk, P (rep k (rep l a))) (seq_diagram_of_over P _) :=
  -- sorry

  -- definition f_rep_equiv_rep_f'
  --   : seq_colim (λk, P (rep (succ k) a)) ≃
  --   @seq_colim (λk, P (rep k (f a))) (seq_diagram_of_over _ _) :=
  -- begin

  -- end

  definition seq_colim_over [unfold 5] (x : seq_colim A) : Type.{v} :=
  begin
    fapply seq_colim.elim_type_on x,
    { intro n a, exact seq_colim (λk, P (rep k a))},
    { intro n a, symmetry,
      refine !shift_equiv ⬝e !f_rep_equiv_rep_f}
  end

  -- needed for seq_colim_over2
  definition glue_tr_g (p : P a) : transport (seq_colim_over P) (glue a)
    (@ι _ (seq_diagram_of_over P (f a)) 0 (g p)) = @ι _ _ 0 p :=
  sorry

--  set_option pp.notation false
  variable {P}
  definition seq_colim_over1 (v : Σ(x : seq_colim A), seq_colim_over P x)
    : seq_colim (λn, Σ(x : A n), P x) :=
  begin
    induction v with a p,
    induction a,
    { esimp at p, induction p with k p,
      { exact ι ⟨rep k a, p⟩},
      { apply glue}},
    { esimp, apply arrow_pathover_left, intro x, esimp at x,
      induction x with k p k p,
      { esimp, apply pathover_of_tr_eq, exact sorry},
      { exact sorry}}
  end

  definition seq_colim_over2 (a : seq_colim (λn, Σ(x : A n), P x)) :
    Σ(x : seq_colim A), seq_colim_over P x :=
  begin
  induction a with n v n v,
  { induction v with a p, exact ⟨ι a, @ι _ _ 0 p⟩},
  { induction v with a p, esimp [seq_diagram_sigma], fapply sigma_eq,
      apply glue,
      esimp, apply pathover_of_eq_tr, exact sorry}
  end

  variable (P)
  definition seq_colim_over_equiv [constructor]
    : (Σ(x : seq_colim A), seq_colim_over P x) ≃ seq_colim (λn, Σ(x : A n), P x) :=
  equiv.MK seq_colim_over1
           seq_colim_over2
           sorry
           sorry

  end over

end seq_colim