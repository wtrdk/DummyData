#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

if [ -z "$1" ] || [ -z "$2" ]
then
    echo "Please specify how many random products would you like to generate, and what filename should be used" 1>&2
    echo "example: ${bold}./wooproductgen.sh 30 woo${normal}" 1>&2
    echo "This will generate ${bold}30${normal} random random products in a file called ${bold}woo.csv${normal}" 1>&2
    exit 0
fi

X=0

#set category array
categories=("Shoes" "T-Shirts" "Jeans" "Pants" "Dresses" "Shorts" "Sweaters" "Jackets" "Underwear" "Skirts" "Suits" "Jewelery")

#set tag array
tags=("cat" "dog" "rabbit" "snake" "baseball" "soccer" "football" "tennis" "cycling" "music" "rock" "metal" "folk" "pop" "cartoon" "movies" "series")

#set attribute array
attributes=("XS" "S" "M" "L" "XL" "Red" "Blue" "Ÿellow" "Green" "Purple" "Pink" "Black" "White" "Leather" "Silk" "Cotton" "Wool" "Canvas" "Fleece" "Denim" "Satin")

#write csv header to file
echo "post_title,post_content,sku,post_status,categories,tags,attributes,regular_price,sale_price,visibility,is_in_stock,stock,images,tax:product_type,tax:product_cat,tax:product_tag" >> $2.csv

while [ "$X" -lt "$1" ]
do
    #define random price and decimal
    price=$(jot -r 1  200 450)
    decimal=$(jot -r 1 0 99)
    
    #randomize if item has sale price or not
    sale=$(jot -r 1 1 200)
    
    #define random sale price and decimal
    saleprice=$(jot -r 1  1 200)
    saledecimal=$(jot -r 1 0 99)
    
    #randomize category from array
    randomizer_cat=$$$(date +%s)
    category=${categories[$randomizer_cat % ${#categories[@]}]}
    
    #randomize tag from array
    randomizer_tag=$$$(date +%s)
    product_tag=${tags[$randomizer_tag % ${#tags[@]}]}
    
    #randomize attributes from array
    randomizer_attr=$$$(date +%s)
    product_attr=${attributes[$randomizer_attr % ${#attributes[@]}]}
    
    #set default status for curl-check
    curlstatus="404"
    
    #check if image exists and set the image for the product
    while [ "$curlstatus" -eq "404" ]
    do
        pic=$(jot -r 1 1 999)
        curlstatus=$(curl -s --head -w %{http_code} http://picsum.photos/200/200/?image=$pic -o /dev/null)
        images="https://picsum.photos/200/200/?image=$pic"
        #echo $X,$curlstatus
    done
    
    #randomize title
    post_title_adj=$(gshuf -n1 adj.txt)
    post_title_noun=$(gshuf -n1 noun.txt)
    post_title=$post_title_adj" "$post_title_noun
    
    #randomize content
    post_content=$(gshuf -n25 /usr/share/dict/words)
    
    #set SKU
    sku_rand=$(jot -r 1 10000 99999)
    sku="WOO-SQR-"$sku_rand
    
    #set post status
    post_status="publish"
    
    #set regular price
    regular_price="$price.$decimal"
    
    #if product has sale price set sale price
    if [ $sale -gt 100 ]
    then
        sale_price="$saleprice.$saledecimal"
    else
        sale_price=""
    fi
    
    #extra fields
    visibility="visible"
    
    stock_rand=$(jot -r 1  -10 50)
    if [ $stock_rand -gt 0 ]
    then
        is_in_stock="instock"
        stock=$(jot -r 1  1 50)
    else
        is_in_stock=""
        stock="0"
    fi
    
    tax_product_type="simple"
    tax_product_cat="woo_test"
    tax_product_tag="woo_tag"
    
    #write line to csv file
    echo $post_title,$post_content,$sku,$post_status,$category,$product_tag,$product_attr,$regular_price,$sale_price,$visibility,$is_in_stock,$stock,$images,$tax_product_type,$tax_product_cat,$tax_product_tag >> $2.csv
    
    #show product counter
    echo -ne "$X"'\r'
    
    let "X = X + 1"
done

echo "Finished generating $1 products in file $2.csv!" 1>&2