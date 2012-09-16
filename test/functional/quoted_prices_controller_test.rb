require 'test_helper'

class QuotedPricesControllerTest < ActionController::TestCase
  setup do
    @quoted_price = quoted_prices(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:quoted_prices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create quoted_price" do
    assert_difference('QuotedPrice.count') do
      post :create, quoted_price: { currency: @quoted_price.currency, name: @quoted_price.name }
    end

    assert_redirected_to quoted_price_path(assigns(:quoted_price))
  end

  test "should show quoted_price" do
    get :show, id: @quoted_price
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @quoted_price
    assert_response :success
  end

  test "should update quoted_price" do
    put :update, id: @quoted_price, quoted_price: { currency: @quoted_price.currency, name: @quoted_price.name }
    assert_redirected_to quoted_price_path(assigns(:quoted_price))
  end

  test "should destroy quoted_price" do
    assert_difference('QuotedPrice.count', -1) do
      delete :destroy, id: @quoted_price
    end

    assert_redirected_to quoted_prices_path
  end
end
