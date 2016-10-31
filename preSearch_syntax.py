# coding=utf-8

"""
Pre process query sentences only with syntax
"""
from syntax import pos, syn_tree, build_tree, show_tree, get_sub_trees_by_tag, get_chunk
from lexical import remove_stopwords
from tree import Node


def flatten(items, seqtypes=(list, tuple)):
    for i, x in enumerate(items):
        while i < len(items) and isinstance(items[i], seqtypes):
            items[i:i+1] = items[i]
    return items


def prepare_query(list_tokens):
    list_tokens = set(list_tokens)
    return remove_stopwords(list_tokens)


def replace_found(text,pattern):
    for pat in pattern:
        print pat
        text = re.sub(pat,'',text)

    return text


def find_compatibles(tree):
    sub = flatten(get_sub_trees_by_tag(tree, 'PP'))
    for st in sub:
        if st is not None:
            sub_sub = flatten(get_sub_trees_by_tag(st, 'P'))
            preposition = flatten(get_chunk(sub_sub[0]))
            if preposition in ['para','de']:
                compatibles.append(get_chunk(st))
            if preposition in ['com']:
                subjectives.append(get_chunk(st))


def find_subjectives(tree):
    sub = flatten(get_sub_trees_by_tag(tree, 'A'))
    for st in sub:
        if st is not None:
            subjectives.append(get_chunk(st))


def find_product_category(tree):
    sub = flatten(get_sub_trees_by_tag(tree, 'N'))
    for st in sub:
        if st is not None:
            product_category.append(get_chunk(st))


def filter_product_category():
    filtered_product_category = []
    global product_category

    for p in product_category:
        if (
        p not in flatten(compatibles) and 
        p not in flatten(subjectives) and 
        p not in flatten(relationals) and 
        p not in flatten(thematics) and 
        p not in flatten(features)
        ):
            filtered_product_category.append(p)

    product_category = filtered_product_category


def what_to_search(text):
    #
    # Syntax tree
    #
    syn_tree_result = syn_tree(text)
    print syn_tree_result
    with open('temp/parsed_query.txt') as result:
        syn_tree_result = result.readlines()
        tree = build_tree(syn_tree_result[0])

        find_compatibles(tree)
        find_product_category(tree)
        find_subjectives(tree)
        filter_product_category()

    print "======================================="
    print "Asked: {}".format(text)
    print "Product/Category: " + " ".join(prepare_query(flatten(product_category)))
    print "Features: " + " ".join([str(tuple) for tuple in flatten(features)])
    print "Compatibles: " + " ".join(flatten(compatibles))
    print "Subjectives: " + " ".join(flatten(subjectives))
    print "Non-product: " + " ".join([str(tuple) for tuple in flatten(non_products)])


# Global Variable
product_category = []
features = []
thematics = []
relationals = []
abbr_symb_slang = []
subjectives = []
compatibles = []
non_products = []

text2 = "Máquina de café Nespresso Essenza automática C101 preta - 110v"

print pos(text2.lower())

#text = 'Aparelho para cortar grama'
#text = 'Quero comprar um presente, para minha mãe, pagar com cartão de crédito em 3 vezes, e quero que seja entregue na avenida Paulista, na semana que vem'
#text = 'Capa linda para celular com 32 GB'
#text = 'Fone de ouvido branco Sony abaixo de R$ 200 para tablet de 7"'
#text = 'Celular rápido'
#text = 'celular com tela resistente'
#text = 'Aparelho para cortar grama'
#text = 'celular lindo com tela forte para natação'
#what_to_search(text)

