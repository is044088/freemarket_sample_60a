class PurchaseController < ApplicationController
  require 'payjp'

  def show
    card = Card.where(user_id: current_user.id).first
    if card.blank?
      #登録された情報がない場合にカード登録画面に移動
      redirect_to controller: "card", action: "new"
    else
      Payjp.api_key = 'sk_test_a0029dc5466705b77c5d7bab'
      #保管した顧客IDでpayjpから情報取得
      customer = Payjp::Customer.retrieve(card.customer_id)
      #保管したカードIDでpayjpから情報取得、カード情報表示のためインスタンス変数に代入
      @default_card_information = customer.cards.retrieve(card.card_id)
    end
  end

  def pay
    card = Card.where(user_id: current_user.id).first
    Payjp.api_key = 'sk_test_a0029dc5466705b77c5d7bab'
    Payjp::Charge.create(
    amount: 6000,
    customer: card.customer_id, #顧客ID
    currency: 'jpy',
  )
  redirect_to action: 'done' #完了画面に移動
  end

end
