class ItemsController < ApplicationController

  require 'nokogiri'
  require 'open-uri'
  require 'amazon/ecs'
  require 'peddler'
  require 'uri'

  before_action :authenticate_user!

  def generate
    @user = current_user.email
  end

  def convert

    body = params[:data]
    body = JSON.parse(body)
    type = body[0]
    list = body[1]
    pnum = body[2]

    key = []

    for j in 0..4
      if (j + 5 * (pnum - 1)) > list.length-1 then
        break
      end
      if list[j + 5 * (pnum - 1)][0] == "" then
        break
      end

      ta = list[j + 5 * (pnum - 1)][0]
      key[j] = ta
    end

    user = current_user.email

    saws = ENV["AWS_ACCESS_KEY_ID"]
    skey = ENV["AWS_SECRET_ACCESS_KEY"]
    sid = "A3449AXENJUW3T"
    logger.debug(saws)
    logger.debug(skey)

    client = MWS.products(
      primary_marketplace_id: "A1VC38T7YXB528",
      merchant_id: sid,
      aws_access_key_id: saws,
      aws_secret_access_key: skey
    )

    parser = client.get_matching_product_for_id("JAN", key)
    doc = Nokogiri::XML(parser.body)
    doc.remove_namespaces!

    res = []
    q = 0
    for tas in key
      temp = doc.xpath("//GetMatchingProductForIdResult[@Id='" + tas + "']")[0]
      asin = temp.xpath('.//ASIN')[0]
      if asin != nil then
        asin = asin.text
        res[q] = asin
        q += 1
        logger.debug(asin)
      else
        res[q] = ""
        q += 1
      end
    end

    render json: res
  end

end
