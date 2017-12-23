class ItemsController < ApplicationController

  require 'nokogiri'
  require 'open-uri'
  require 'amazon/ecs'
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

    key = ""

    for j in 0..9
      if (j + 10 * (pnum - 1)) > list.length-1 then
        break
      end
      if list[j + 10 * (pnum - 1)][0] == "" then
        break
      end

      ta = list[j + 10 * (pnum - 1)][0]
      key = key + ta + ","
    end

    key = key[0..(key.length-2)]
    user = current_user.email

    aaws = "AKIAJWYZXQ57QND7DNEA"
    akey = "iNDLIrTVK84d/qxVHAWfra97nfV9eOMLaYOBMexf"
    aid = "mamegomari-22"

    Amazon::Ecs.configure do |options|
      options[:AWS_access_key_id] = aaws
      options[:AWS_secret_key] = akey
      options[:associate_tag] = aid
    end

    try = 0
    times = 5
    if type == "ASIN" then
      begin
        aws = Amazon::Ecs.item_lookup(key, {:response_group => 'Large,OfferFull',:country => 'jp'})
        try += 1
      rescue
        sleep(1)
        retry if try < times
      end
    else
      begin
        aws = Amazon::Ecs.item_lookup(key, {:IdType => 'EAN', :SearchIndex => 'All',:response_group => 'Large,OfferFull',:country => 'jp'})
        try += 1
      rescue
        sleep(1)
        retry if try < times
      end
    end
    res = []
    k = 0
    j = 0

    if type == "ASIN" then
      tch = aws.items.each do |item|
        jan = item.get('ItemAttributes/EAN')
        res[k] = jan
        k += 1
      end
    else
      for j in 0..9
        if (j + 10 * (pnum - 1)) > list.length-1 then
          break
        end
        if list[j + 10 * (pnum - 1)][0] == "" then
          break
        end

        jan = list[j + 10 * (pnum - 1)][0]

        tch = aws.items.each do |item|
          jan2 = item.get('ItemAttributes/EAN').to_s
          if jan == jan2 then
            res[j] = item.get("ASIN").to_s
          end
          k += 1
        end
      end
    end

    render json: res
  end

end
