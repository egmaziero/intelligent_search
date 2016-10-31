# coding=utf-8

"""
Semantic module.
    It provides:
    - Synonyms
    - Antonyms
    - Semantic Role Labeling (SRL)
"""
import nltk
import nlpnet
import nlpnet.config


nlpnet.set_data_dir('nlpnet') # replace by data


__all__ = ['synsets', 'antonyms', 'srl']


def synsets(token):
    """
    get a set of words which are synonyms to the token
    :param token1: one token string
    :return: list
    """
    synset = []

    return synset

def antonyms(token):
    """
    get a set of words which are antonyms to the token
    :param token1: one token string
    :return: list
    """
    antonym_set = []

    return antonym_set

def srl(text):
    """
    get the verbal arguments of the given sentence
    :param sentence:  [str list]
    :return: {dic}
    """
    taggerSRL = nlpnet.SRLTagger()
    srl_result = taggerSRL.tag(text)
    
    return srl_result
