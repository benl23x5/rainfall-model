(* Auction example: see also demo/Auction.hs *)
theory Example_Auction
  imports Dynamic
begin
section \<open>Rule names\<close>

definition "auction_bid_rn    = rule_name ''auction_bid''"
definition "auction_accept_rn = rule_name ''auction_accept''"
definition "broker_reserve_rn = rule_name ''broker_reserve''"

definition "auction_rules = {auction_bid_rn, auction_accept_rn}"
definition "broker_rules  = {broker_reserve_rn}" 

section \<open>Fact definitions\<close>
(*
auction side:
fact Accept  [lot: Symbol, broker: Party, price: Nat]
fact Item    [lot: Symbol, desc: Text, ask: Nat]
fact Invoice [broker: Party, buyer: Party, desc: Text, amount: Nat]
fact Bid     [lot: Symbol, broker: Party, buyer: Party, price: Nat]
fact Offer   [lot: Symbol, broker: Party, buyer: Party, price: Nat]

broker side:
fact Order   [broker: Party, buyer: Party, desc: Text, limit: Nat]
fact Reserve [broker: Party, buyer: Party, lot: Nat, offer: Nat]
fact Budget  [broker: Party, buyer: Party, budget: Nat]
*)

(* Boilerplate for fact definitions: these would be a lot cleaner if we used a shallow embedding for the types,
   but they're all pretty mechanical anyway.
*)
definition "mk_AcceptPayload lot broker price = vpair (vlit (lsymbol lot)) (vpair (vlit (lparty broker)) (vlit (lnat price)))"
fun tk_AcceptPayload where
  "tk_AcceptPayload (vpair (vlit (lsymbol lot)) (vpair (vlit (lparty broker)) (vlit (lnat price)))) = (lot, broker, price)"
| "tk_AcceptPayload _ = undefined" 

definition "Accept_lot    =       fst o tk_AcceptPayload o fact_value"
definition "Accept_broker = fst o snd o tk_AcceptPayload o fact_value"
definition "Accept_ask    = snd o snd o tk_AcceptPayload o fact_value"

definition "Accept = fact_ctor ''Accept''"
definition "mk_Accept lot broker price by obs = \<lparr>fact_name = Accept, fact_value = mk_AcceptPayload lot broker price, fact_by = by, fact_obs = obs, fact_rules = auction_rules\<rparr>"


definition "mk_ItemPayload lot desc ask = vpair (vlit (lsymbol lot)) (vpair (vlit (lsymbol desc)) (vlit (lnat ask)))"
fun tk_ItemPayload where
  "tk_ItemPayload (vpair (vlit (lsymbol lot)) (vpair (vlit (lsymbol desc)) (vlit (lnat ask)))) = (lot, desc, ask)"
| "tk_ItemPayload _ = undefined" 

definition "Item_lot  =       fst o tk_ItemPayload o fact_value"
definition "Item_desc = fst o snd o tk_ItemPayload o fact_value"
definition "Item_ask  = snd o snd o tk_ItemPayload o fact_value"

definition "Item = fact_ctor ''Item''"
definition "mk_Item lot desc ask by obs = \<lparr>fact_name = Item, fact_value = mk_ItemPayload lot desc ask, fact_by = by, fact_obs = obs, fact_rules = auction_rules\<rparr>"


definition "mk_InvoicePayload broker buyer desc amount = vpair (vlit (lparty broker)) (vpair (vlit (lparty buyer)) (vpair (vlit (lsymbol desc)) (vlit (lnat amount))))"
fun tk_InvoicePayload where
  "tk_InvoicePayload (vpair (vlit (lparty broker)) (vpair (vlit (lparty buyer)) (vpair (vlit (lsymbol desc)) (vlit (lnat amount))))) = (broker, buyer, desc, amount)"
| "tk_InvoicePayload _ = undefined" 

definition "Invoice_broker =             fst o tk_InvoicePayload o fact_value"
definition "Invoice_buyer  =       fst o snd o tk_InvoicePayload o fact_value"
definition "Invoice_desc   = fst o snd o snd o tk_InvoicePayload o fact_value"
definition "Invoice_amount = snd o snd o snd o tk_InvoicePayload o fact_value"

definition "Invoice = fact_ctor ''Invoice''"
definition "mk_Invoice broker buyer desc amount by obs = \<lparr>fact_name = Invoice, fact_value = mk_InvoicePayload broker buyer desc amount, fact_by = by, fact_obs = obs, fact_rules = auction_rules\<rparr>"


definition "mk_BidPayload lot broker buyer price = vpair (vlit (lsymbol lot)) (vpair (vlit (lparty broker)) (vpair (vlit (lparty buyer)) (vlit (lnat price))))"
fun tk_BidPayload where
  "tk_BidPayload (vpair (vlit (lsymbol lot)) (vpair (vlit (lparty broker)) (vpair (vlit (lparty buyer)) (vlit (lnat price))))) = (lot, broker, buyer, price)"
| "tk_BidPayload _ = undefined" 

definition "Bid_lot    =             fst o tk_BidPayload o fact_value"
definition "Bid_broker =       fst o snd o tk_BidPayload o fact_value"
definition "Bid_buyer  = fst o snd o snd o tk_BidPayload o fact_value"
definition "Bid_price  = snd o snd o snd o tk_BidPayload o fact_value"

definition "Bid = fact_ctor ''Bid''"
definition "mk_Bid lot broker buyer price by obs = \<lparr>fact_name = Bid, fact_value = mk_BidPayload lot broker buyer price, fact_by = by, fact_obs = obs, fact_rules = auction_rules\<rparr>"

(* Offer has same payload as Bid *)
definition "mk_OfferPayload = mk_BidPayload"
definition "tk_OfferPayload = tk_BidPayload"
definition "Offer_lot    = Bid_lot"
definition "Offer_broker = Bid_broker"
definition "Offer_buyer  = Bid_buyer"
definition "Offer_price  = Bid_price"

definition "Offer = fact_ctor ''Offer''"
definition "mk_Offer lot broker buyer price by obs = \<lparr>fact_name = Offer, fact_value = mk_OfferPayload lot broker buyer price, fact_by = by, fact_obs = obs, fact_rules = auction_rules\<rparr>"


definition "mk_OrderPayload broker buyer desc limit budget = vpair (vlit (lparty broker)) (vpair (vlit (lparty buyer)) (vpair (vlit (lsymbol desc)) (vpair (vlit (lnat limit)) (vlit (lnat budget)))))"
fun tk_OrderPayload where
  "tk_OrderPayload (vpair (vlit (lparty broker)) (vpair (vlit (lparty buyer)) (vpair (vlit (lsymbol desc)) (vpair (vlit (lnat limit)) (vlit (lnat budget)))))) = (broker, buyer, desc, limit, budget)"
| "tk_OrderPayload _ = undefined" 

definition "Order_broker =                   fst o tk_OrderPayload o fact_value"
definition "Order_buyer  =             fst o snd o tk_OrderPayload o fact_value"
definition "Order_desc   =       fst o snd o snd o tk_OrderPayload o fact_value"
definition "Order_limit  = fst o snd o snd o snd o tk_OrderPayload o fact_value"
definition "Order_budget = snd o snd o snd o snd o tk_OrderPayload o fact_value"

definition "Order = fact_ctor ''Order''"
definition "mk_Order broker buyer desc limit budget by obs = \<lparr>fact_name = Order, fact_value = mk_OrderPayload broker buyer desc limit budget, fact_by = by, fact_obs = obs, fact_rules = broker_rules\<rparr>"


definition "mk_ReservePayload broker buyer lot amount = vpair (vlit (lparty broker)) (vpair (vlit (lparty buyer)) (vpair (vlit (lsymbol lot)) (vlit (lnat amount))))"
fun tk_ReservePayload where
  "tk_ReservePayload (vpair (vlit (lparty broker)) (vpair (vlit (lparty buyer)) (vpair (vlit (lsymbol lot)) (vlit (lnat amount))))) = (broker, buyer, lot, amount)"
| "tk_ReservePayload _ = undefined" 

definition "Reserve_broker =             fst o tk_ReservePayload o fact_value"
definition "Reserve_buyer  =       fst o snd o tk_ReservePayload o fact_value"
definition "Reserve_lot    = fst o snd o snd o tk_ReservePayload o fact_value"
definition "Reserve_amount = snd o snd o snd o tk_ReservePayload o fact_value"

definition "Reserve = fact_ctor ''Reserve''"
definition "mk_Reserve broker buyer lot amount by obs = \<lparr>fact_name = Reserve, fact_value = mk_ReservePayload broker buyer lot amount, fact_by = by, fact_obs = obs, fact_rules = broker_rules\<rparr>"


definition "mk_BudgetPayload broker buyer budget remain = vpair (vlit (lparty broker)) (vpair (vlit (lparty buyer)) (vpair (vlit (lnat budget)) (vlit (lnat remain))))"
fun tk_BudgetPayload where
  "tk_BudgetPayload (vpair (vlit (lparty broker)) (vpair (vlit (lparty buyer)) (vpair (vlit (lnat budget)) (vlit (lnat remain))))) = (broker, buyer, budget, remain)"
| "tk_BudgetPayload _ = undefined" 

definition "Budget_broker =             fst o tk_BudgetPayload o fact_value"
definition "Budget_buyer  =       fst o snd o tk_BudgetPayload o fact_value"
definition "Budget_budget = fst o snd o snd o tk_BudgetPayload o fact_value"
definition "Budget_remain = snd o snd o snd o tk_BudgetPayload o fact_value"

definition "Budget = fact_ctor ''Budget''"
definition "mk_Budget broker buyer budget remain by obs = \<lparr>fact_name = Budget, fact_value = mk_BudgetPayload broker buyer budget remain, fact_by = by, fact_obs = obs, fact_rules = broker_rules\<rparr>"

lemmas payload_defs =
  mk_AcceptPayload_def Accept_lot_def Accept_broker_def Accept_ask_def mk_Accept_def
  mk_ItemPayload_def Item_lot_def Item_desc_def Item_ask_def mk_Item_def
  mk_InvoicePayload_def Invoice_broker_def Invoice_buyer_def Invoice_desc_def Invoice_amount_def mk_Invoice_def
  mk_BidPayload_def Bid_lot_def Bid_broker_def Bid_buyer_def Bid_price_def mk_Bid_def
  mk_OfferPayload_def tk_OfferPayload_def Offer_lot_def Offer_broker_def Offer_buyer_def Offer_price_def mk_Offer_def
  mk_OrderPayload_def Order_broker_def Order_buyer_def Order_desc_def Order_limit_def Order_budget_def mk_Order_def
  mk_ReservePayload_def Reserve_broker_def Reserve_buyer_def Reserve_lot_def Reserve_amount_def mk_Reserve_def
  mk_BudgetPayload_def Budget_broker_def Budget_buyer_def Budget_budget_def Budget_remain_def mk_Budget_def

lemmas fact_ctor_defs =
  Accept_def Item_def Invoice_def Bid_def Offer_def Order_def Reserve_def Budget_def

(* Fact variables *)
definition "accept_v  = fact_var ''accept''"
definition "item_v    = fact_var ''item''"
definition "bid_v     = fact_var ''bid''"
definition "offer_v   = fact_var ''offer''"
definition "order_v   = fact_var ''order''"
definition "reserve_v = fact_var ''reserve''"
definition "budget_v  = fact_var ''budget''"

lemmas fact_var_defs =
  accept_v_def item_v_def bid_v_def offer_v_def order_v_def reserve_v_def budget_v_def


section \<open>Auction bid rule\<close>

definition "match_any_when var factctor when consume auth_f = match var (gather_when factctor when) select_any (consume_weight (\<lambda>h. consume)) (gain_auth auth_f)"
definition "match_any var factctor consume auth_f = match_any_when var factctor (\<lambda>h. True) consume auth_f"
definition "match_first_when var factctor when fstby consume auth_f = match var (gather_when factctor when) (select_first fstby) (consume_weight (\<lambda>h. consume)) (gain_auth auth_f)"

definition
  "auction_bid = rule auction_bid_rn
  [ match_any bid_v Bid 1 (\<lambda>h. {Bid_buyer (h bid_v), Bid_broker (h bid_v)})
  , match_any_when item_v Item
        (\<lambda>h. Item_lot (h item_v) = Bid_lot (h bid_v) \<and> Bid_price (h bid_v) < Item_ask (h item_v))
        0
        (\<lambda>h. {party ''Mark''})
  ]
  (\<lambda>h. {#
    mk_Offer (Item_lot (h item_v)) (Bid_broker (h bid_v)) (Bid_buyer (h bid_v)) (Bid_price (h bid_v))
          {Bid_buyer (h bid_v), Bid_broker (h bid_v), party ''Mark''}
          {party ''Mark''}
  #})"


definition
  "auction_accept = rule auction_accept_rn
  [ match_any accept_v Accept 1 (\<lambda>h. {party ''Mark''})
  , match_any_when offer_v Offer
        (\<lambda>h. Offer_lot (h offer_v) = Accept_lot (h accept_v) \<and> Offer_broker (h offer_v) = Accept_broker (h accept_v))
        1
        (\<lambda>h. {Offer_broker (h offer_v), Offer_buyer (h offer_v)})
  , match_any_when item_v Item
        (\<lambda>h. Offer_lot (h offer_v) = Item_lot (h item_v))
        1
        (\<lambda>h. {party ''Mark''})

  ]
  (\<lambda>h. {#
    mk_Invoice (Offer_broker (h offer_v)) (Offer_buyer (h offer_v)) (Item_desc (h item_v)) (Offer_price (h offer_v))
          {Offer_buyer (h offer_v), Offer_broker (h offer_v), party ''Mark''}
          {}
  #})"


definition
  "broker_reserve = rule broker_reserve_rn
  [ match_any order_v Order 0 (\<lambda>h. {Order_buyer (h order_v)})
  , match_first_when item_v Item
        (\<lambda>h. Item_desc (h item_v) = Order_desc (h order_v))
        (\<lambda>h. Item_ask (h item_v))
        0
        (\<lambda>h. {party ''Mark''})
  , match_any_when reserve_v Reserve
        (\<lambda>h. Reserve_broker (h reserve_v) = Order_broker (h order_v)
           \<and> Reserve_buyer  (h reserve_v) = Order_buyer  (h order_v)
           \<and> Reserve_lot    (h reserve_v) = Item_lot     (h item_v)
           \<and> Reserve_amount (h reserve_v) \<le> Order_limit  (h order_v))
        1
        (\<lambda>h. {Reserve_broker (h reserve_v)})
  , match_any_when budget_v Budget
        (\<lambda>h. Reserve_broker (h reserve_v) = Budget_broker (h budget_v)
           \<and> Reserve_buyer  (h reserve_v) = Budget_buyer  (h budget_v)
           \<and> Reserve_amount (h reserve_v) \<le> Budget_remain (h budget_v))
        1
        (\<lambda>h. {Budget_broker (h budget_v)})
  ]
  (\<lambda>h. {#
    mk_Budget (Budget_broker (h budget_v)) (Budget_buyer (h budget_v)) (Budget_budget (h budget_v))
          (Budget_remain (h budget_v) - Reserve_amount (h reserve_v))
          {Budget_broker (h budget_v)}
          {}
  , mk_Bid (Item_lot (h item_v)) (Reserve_broker (h reserve_v)) (Order_buyer (h order_v)) (Reserve_amount (h reserve_v))
          {Reserve_broker (h reserve_v), Order_buyer (h order_v)}
          {party ''Mark''}
  #})"

lemmas rule_defs =
  match_any_when_def match_any_def match_first_when_def
  auction_bid_def auction_accept_def broker_reserve_def

section \<open>Invariants\<close>

definition facts_of_type :: "fact_ctor \<Rightarrow> store \<Rightarrow> store" where
"facts_of_type ctor s = {# f \<in># s. fact_name f = ctor #}"

definition "bids_for_budget s b =
  {# f \<in># facts_of_type Bid     s. Bid_buyer     f = Budget_buyer b \<and> Bid_broker     f = Budget_broker b #}"
definition "invoices_for_budget s b =
  {# f \<in># facts_of_type Invoice s. Invoice_buyer f = Budget_buyer b \<and> Invoice_broker f = Budget_broker b #}"
definition "offers_for_budget s b =
  {# f \<in># facts_of_type Offer s. Offer_buyer f = Budget_buyer b \<and> Offer_broker f = Budget_broker b #}"

definition "budget_matches_order b order =
  (Order_buyer order = Budget_buyer b \<and> Order_broker order = Budget_broker b)"
(* TODO: Budget is missing the description, so we only allow one order per buyer.
   We should add the restriction that budgets are specific to order descriptions *)

definition "budgets_for_order s order =
  {# b \<in># facts_of_type Budget s. budget_matches_order b order #}"

(* Invariant: a Budget is OK if the sum of its bids and invoices are less than the budget.
   The remaining must be the budget minus whatever has been committed in bids and invoices. *)
definition budget_ok :: "store \<Rightarrow> fact \<Rightarrow> bool" where
"budget_ok s b = 
    (let bids        = bids_for_budget s b
  in let invoices    = invoices_for_budget s b
  in let offers      = offers_for_budget s b
  in let sum_all = sum_mset (image_mset Bid_price      bids)
                 + sum_mset (image_mset Invoice_amount invoices)
                 + sum_mset (image_mset Offer_price    offers)
  in sum_all \<le> Budget_budget b \<and> Budget_remain b = Budget_budget b - sum_all)"

(* Invariant: an Order is OK if all the budgets (there should only be one) are OK *)
definition order_ok :: "store \<Rightarrow> fact \<Rightarrow> bool" where
"order_ok s order = 
  ((size (budgets_for_order s order) \<le> 1) \<and>
  (\<forall> b \<in># budgets_for_order s order. budget_ok s b \<and> Budget_budget b = Order_budget order))"

(* Invariant: a store is OK if all the orders are OK *)
definition store_ok :: "store \<Rightarrow> bool" where
"store_ok s = 
  (\<forall> order \<in># facts_of_type Order s. order_ok s order)"

lemmas invariant_helper_defs =
  facts_of_type_def bids_for_budget_def invoices_for_budget_def offers_for_budget_def
  budget_matches_order_def budgets_for_order_def

lemmas invariant_defs =
  invariant_helper_defs budget_ok_def order_ok_def store_ok_def

(* Empty store is ok *)
lemma empty_store_ok: "store_ok {#}"
  by (simp add: invariant_defs)

(* Adding a new fact doesn't affect budgets *)
lemma budget_ok__add_irrelevant_fact:
    "budget_ok s b
 \<Longrightarrow> fact_name f \<noteq> Invoice
 \<Longrightarrow> fact_name f \<noteq> Bid
 \<Longrightarrow> fact_name f \<noteq> Offer
 \<Longrightarrow> budget_ok ({#f#} \<union># s) b"
  unfolding invariant_defs
  by simp

lemma order_ok__add_irrelevant_fact:
    "order_ok s or
 \<Longrightarrow> fact_name f \<noteq> Invoice
 \<Longrightarrow> fact_name f \<noteq> Bid
 \<Longrightarrow> fact_name f \<noteq> Budget
 \<Longrightarrow> fact_name f \<noteq> Offer
 \<Longrightarrow> order_ok ({#f#} \<union># s) or"
  unfolding invariant_defs
  by auto

lemma store_ok__add_irrelevant_fact:
    "store_ok s
 \<Longrightarrow> fact_name f \<noteq> Invoice
 \<Longrightarrow> fact_name f \<noteq> Bid
 \<Longrightarrow> fact_name f \<noteq> Budget
 \<Longrightarrow> fact_name f \<noteq> Order
 \<Longrightarrow> fact_name f \<noteq> Offer
 \<Longrightarrow> store_ok ({#f#} \<union># s)"
  unfolding invariant_defs
  by force

(* The customer can add a new order that doesn't conflict with existing order *)
lemma store_ok__add_order:
    "store_ok s
 \<Longrightarrow> fact_name or = Order
 \<Longrightarrow> budgets_for_order s or = {#}
 \<Longrightarrow> store_ok ({#or#} \<union># s)"
  using multi_member_split
  by (force simp add: store_ok_def order_ok_def
      budgets_for_order_def facts_of_type_def
      fact_ctor_defs budget_ok__add_irrelevant_fact)

(* The broker can add a new budget for which there are no pre-existing bids or invoices *)
lemma store_ok__add_budget:
    "store_ok s
 \<Longrightarrow> fact_name b = Budget
 \<Longrightarrow> Budget_remain b = Budget_budget b
 \<Longrightarrow> bids_for_budget s b = {#}
 \<Longrightarrow> invoices_for_budget s b = {#}
 \<Longrightarrow> offers_for_budget s b = {#}
 \<Longrightarrow> (\<forall>or \<in># facts_of_type Order s. budget_matches_order b or \<longrightarrow> budgets_for_order s or = {#} \<and> Order_budget or = Budget_budget b)
 \<Longrightarrow> store_ok ({#b#} \<union># s)"
  apply (simp add: invariant_defs fact_ctor_defs)
  by (intro allI conjI; force)


lemma budget_ok__bid_to_offer:
  "budget_ok (add_mset fb s) b \<Longrightarrow>
   fact_name fb = Bid \<Longrightarrow>
   fact_name fo = Offer \<Longrightarrow>
   Offer_lot fo = Bid_lot fb \<Longrightarrow>
   Offer_broker fo = Bid_broker fb \<Longrightarrow>
   Offer_buyer fo = Bid_buyer fb \<Longrightarrow>
   Offer_price fo = Bid_price fb \<Longrightarrow>
   budget_ok (add_mset fo s) b"
  apply (simp add: invariant_defs fact_ctor_defs)
  apply (intro allI conjI impI)
   apply (simp add: ab_semigroup_add_class.add_ac(1) add.commute add.left_commute)
  by auto

lemma store_ok__bid_to_offer:
  "store_ok (add_mset fb s) \<Longrightarrow>
   fact_name fb = Bid \<Longrightarrow>
   fact_name fo = Offer \<Longrightarrow>
   Offer_lot fo = Bid_lot fb \<Longrightarrow>
   Offer_broker fo = Bid_broker fb \<Longrightarrow>
   Offer_buyer fo = Bid_buyer fb \<Longrightarrow>
   Offer_price fo = Bid_price fb \<Longrightarrow>
   store_ok (add_mset fo s)"
  apply (simp add: store_ok_def order_ok_def invariant_helper_defs fact_ctor_defs)
  apply (intro allI conjI impI)
  apply (elim conjE)
  using fact_ctor_defs budget_ok__bid_to_offer by fastforce

lemma store_ok__bid_to_offer__mk_Offer:
  "store_ok (add_mset fb s) \<Longrightarrow>
   fact_name fb = Bid \<Longrightarrow>
   store_ok
    (add_mset
      (mk_Offer (Bid_lot fb) (Bid_broker fb) (Bid_buyer fb) (Bid_price fb) by obs)
      s)"
  by (force simp add: payload_defs intro: store_ok__bid_to_offer)

lemma store_ok__auction_bid__ok:
    "store_ok s
 \<Longrightarrow> asub | s \<turnstile> auction_bid \<Down> fread | dspent | dnew | s' FIRE
 \<Longrightarrow> store_ok s'"
  unfolding rule_defs fact_var_defs
  apply (elim EvFire.cases EvExec.cases; clarsimp)
  apply (erule EvMatches.cases; clarsimp; erule EvMatches.cases; clarsimp; erule EvMatches.cases; clarsimp)
  apply (elim EvMatch.cases)
  apply (elim EvGather.cases)
  apply (elim EvGain.cases; clarsimp; elim EvSelect.cases; clarsimp; elim EvConsume.cases; clarsimp)
  by (fastforce simp add: check_gather_def intro: store_ok__bid_to_offer__mk_Offer)

(* TODO unused *)
lemma budget_ok__accept_offer_ok:
      "budget_ok ({#fe, fd, fc#} + s) b \<Longrightarrow>
       fact_name fc = Accept \<Longrightarrow>
       fact_name fd = Offer \<Longrightarrow>
       fact_name fe = Item \<Longrightarrow>
       Accept_lot fc = Item_lot fe \<Longrightarrow>
       Offer_lot fd = Item_lot fe \<Longrightarrow>
       Offer_broker fd = Accept_broker fc \<Longrightarrow>
       budget_ok
        (add_mset
          (mk_Invoice (Accept_broker fc) (Offer_buyer fd) (Item_desc fe) (Offer_price fd) by obs)
          s) b"
  apply (simp add: invariant_defs fact_ctor_defs payload_defs)
  by (intro allI conjI impI; force simp add: add.assoc add.left_commute)

lemma store_ok__accept_offer_ok:
      "store_ok ({#fe, fd, fc#} + s) \<Longrightarrow>
       fact_name fc = Accept \<Longrightarrow>
       fact_name fd = Offer \<Longrightarrow>
       fact_name fe = Item \<Longrightarrow>
       Accept_lot fc = Item_lot fe \<Longrightarrow>
       Offer_lot fd = Item_lot fe \<Longrightarrow>
       Offer_broker fd = Accept_broker fc \<Longrightarrow>
       store_ok
        (add_mset
          (mk_Invoice (Accept_broker fc) (Offer_buyer fd) (Item_desc fe) (Offer_price fd) by obs)
          s)"
  (* TODO clean *)
  apply (simp add: invariant_defs fact_ctor_defs payload_defs)
  apply (intro allI conjI impI)
   apply clarsimp
   apply (elim allE conjE impE)
     apply blast
    apply blast
   apply (simp add: add.assoc add.left_commute)
  apply clarsimp
  apply (erule allE)
  apply (case_tac "Offer_buyer fd = Budget_buyer b"; clarsimp simp add: payload_defs)
  apply (elim allE conjE impE)
       apply blast
      apply blast
   apply simp
  apply (elim allE conjE impE)
    apply blast
   apply blast
  apply simp
  done

lemma store_ok__auction_accept__ok:
    "store_ok s
 \<Longrightarrow> asub | s \<turnstile> auction_accept \<Down> fread | dspent | dnew | s' FIRE
 \<Longrightarrow> store_ok s'"
  unfolding auction_accept_def
    item_v_def accept_v_def bid_v_def offer_v_def
    match_any_def match_any_when_def match_first_when_def
  apply (elim EvFire.cases EvExec.cases; clarsimp)
  apply (erule EvMatches.cases; clarsimp)+
  apply (elim EvMatch.cases)
  apply (elim EvGather.cases)
  apply clarsimp
  apply (elim EvGain.cases; clarsimp)
  apply (elim EvSelect.cases; clarsimp)
  apply (elim EvConsume.cases; clarsimp)
  apply (unfold check_gather_def)
  apply clarsimp
  using store_ok__accept_offer_ok
  by (smt Accept_def Invoice_def Item_def Offer_def char.inject diff_add_mset_swap fact_ctor.inject insert_iff list.inject mk_Invoice_def select_convs(1) set_mset_add_mset_insert set_mset_empty singletonD subset_mset.add_diff_inverse)



lemma store_ok__add_bid_budget_ok:
"store_ok ({#fc, fb#} + s) \<Longrightarrow>
       fa \<in># s \<Longrightarrow>
       f \<in># s \<Longrightarrow>
       fact_name fa = Item \<Longrightarrow>
       Item_desc fa = Order_desc f \<Longrightarrow>
       fact_name f = Order \<Longrightarrow>
       fact_name fb = Reserve \<Longrightarrow>
       fact_name fc = Budget \<Longrightarrow>
       Reserve_broker fb = Budget_broker fc \<Longrightarrow>
       Order_broker f = Budget_broker fc \<Longrightarrow>
       Reserve_buyer fb = Budget_buyer fc \<Longrightarrow>
       Order_buyer f = Budget_buyer fc \<Longrightarrow>
       Reserve_amount fb \<le> Budget_remain fc \<Longrightarrow>
       Reserve_lot fb = Item_lot fa \<Longrightarrow>
       Reserve_amount fb \<le> Order_limit f \<Longrightarrow>
       store_ok
        (add_mset
          (mk_Budget (Budget_broker fc) (Budget_buyer fc) (Budget_budget fc) (Budget_remain fc - Reserve_amount fb)
            buby buobs)
          (add_mset
            (mk_Bid (Item_lot fa) (Budget_broker fc) (Budget_buyer fc) (Reserve_amount fb)
              biby biobs)
            s))"
  unfolding store_ok_def order_ok_def budget_ok_def
    facts_of_type_def bids_for_budget_def invoices_for_budget_def offers_for_budget_def 
    Invoice_def Bid_def Budget_def
    store_ok_def order_ok_def
    budget_matches_order_def
    budgets_for_order_def facts_of_type_def
    Budget_def Order_def Offer_def Item_def Accept_def Reserve_def
    mk_Bid_def mk_BidPayload_def mk_Budget_def mk_BudgetPayload_def
  apply (simp only: Multiset.set_mset_filter
                    Multiset.sup_union_left1
                    Multiset.filter_mset_add_mset
                    Multiset.set_mset_sup
                    Set.mem_Collect_eq
                    Multiset.filter_sup_mset
                    HOL.conj_assoc
                    fact.simps
                    fact_ctor.inject list.inject char.inject HOL.simp_thms if_False if_True
                    Set.ball_simps)
  apply simp
  apply (simp add: Bid_buyer_def Budget_buyer_def Bid_broker_def Budget_broker_def
      Bid_price_def Budget_budget_def Budget_remain_def
      Invoice_amount_def Invoice_buyer_def Invoice_broker_def mk_InvoicePayload_def)
  apply (intro allI impI)
  apply (intro allI conjI impI)
   apply (elim allE conjE impE)
     apply blast
        apply blast
  apply (simp add: Bid_buyer_def Budget_buyer_def Bid_broker_def Budget_broker_def
      Bid_price_def Budget_budget_def Budget_remain_def
      Invoice_amount_def Invoice_buyer_def Invoice_broker_def mk_InvoicePayload_def)


   apply (elim allE conjE impE; blast?)
  apply (smt Nat.le_diff_conv2 ab_semigroup_add_class.add_ac(1) diff_cancel2 le_add_diff_inverse2)

     apply (elim allE conjE impE; blast?)
  apply (simp add: Bid_buyer_def Budget_buyer_def Bid_broker_def Budget_broker_def
      Bid_price_def Budget_budget_def Budget_remain_def
      Invoice_amount_def Invoice_buyer_def Invoice_broker_def mk_InvoicePayload_def)
  using multi_member_split apply force

     apply (erule_tac x="order" in allE)
    apply (case_tac "Order_buyer order = fst (snd (tk_BudgetPayload (fact_value fc)))"; clarsimp)
     apply (simp add: Bid_buyer_def Budget_buyer_def Bid_broker_def Budget_broker_def Bid_price_def Budget_budget_def Budget_remain_def)
     apply (simp add: Bid_buyer_def Budget_buyer_def Bid_broker_def Budget_broker_def Bid_price_def Budget_budget_def Budget_remain_def)

   apply (elim allE conjE impE; blast?; simp)
    apply simp
  by blast


lemma store_ok__broker_reserve__ok:
    "store_ok s
 \<Longrightarrow> asub | s \<turnstile> broker_reserve \<Down> fread | dspent | dnew | s' FIRE
 \<Longrightarrow> store_ok s'"
  unfolding broker_reserve_def
    item_v_def accept_v_def bid_v_def offer_v_def budget_v_def reserve_v_def order_v_def
    match_any_def match_any_when_def match_first_when_def
  apply (elim EvFire.cases EvExec.cases; clarsimp)
  apply (erule EvMatches.cases; clarsimp)+
  apply (elim EvMatch.cases)
  apply (elim EvGather.cases)
  apply clarsimp
  apply (elim EvGain.cases; clarsimp)
  apply (elim EvSelect.cases; clarsimp)
  apply (elim EvConsume.cases; clarsimp)
  apply (unfold check_gather_def)

  apply (rule_tac V="store_ok
        (add_mset
          (mk_Budget (Budget_broker fc) (Budget_buyer fc) (Budget_budget fc) (Budget_remain fc - Reserve_amount fb)
            {Budget_broker fc} {})
          (add_mset
            (mk_Bid (Item_lot fa) (Reserve_broker fb) (Order_buyer f) (Reserve_amount fb) {Reserve_broker fb, Order_buyer f}
              {party ''Mark''})
            (s -
         {#fc, fb#})))" in revcut_rl)

   apply clarsimp
   apply (rule store_ok__add_bid_budget_ok; blast?; simp add: find_firsts_def)
  apply (metis (no_types, lifting) add_mset_remove_trivial mset_subset_eq_single subset_mset.add_diff_assoc2 subset_mset.add_diff_inverse union_single_eq_member)
    apply (smt Budget_def Item_def Reserve_def char.inject fact_ctor.inject insert_iff list.inject set_mset_add_mset_insert set_mset_empty singletonD subset_mset.add_diff_inverse union_iff)
  defer
  apply (smt add_mset_commute add_mset_diff_bothsides add_mset_remove_trivial add_mset_remove_trivial_If diff_union_swap insert_subset_eq_iff)
  by (smt Budget_def Multiset.diff_cancel Order_def Reserve_def add_mset_remove_trivial char.inject fact_ctor.inject insert_DiffM insert_noteq_member list.inject mset_subset_eq_add_mset_cancel subset_mset.add_diff_assoc2 subset_mset.add_diff_inverse subset_mset.sup.orderI subset_mset.sup_bot.right_neutral)

end