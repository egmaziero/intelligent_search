# coding=utf-8

"""
Semantic module.
    It provides:
    - tokenization
    - 
"""
import nltk
import nlpnet
import nlpnet.config

nlpnet.set_data_dir('nlpnet') # replace by data

__all__ = ['remove_stopwords']

#
# reading of stopword_list
#
stopwords_list = []
sw_list = open('corpora/stopwords/portuguese','r')
for sw in sw_list.readlines():
    stopwords_list.append(unicode(sw.strip().lower(),'utf-8'))

def remove_stopwords(list_tokens):
    """
    remove the stopwords of a list of tokens
    :param list_tokens: list
    :return: list
    """
    new_list_tokens = []
    for token in list_tokens:
        if token.lower() not in stopwords_list:
            new_list_tokens.append(token.lower())
    
    return new_list_tokens