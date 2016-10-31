# coding=utf-8

"""
Semantic module.
    It provides:
    - POS
"""
import nltk
import nlpnet
import nlpnet.config
import subprocess
import shlex


from tree import Node

nlpnet.set_data_dir('nlpnet') # replace by data


__all__ = ['pos', 'syn_tree', 'build_tree']


def pos(text):
    """
    get the part-of-speech for tokens of the given sentence
    :param sentence:  [str list]
    :return: list of tuples ('tag','token')
    """
    taggerPOS = nlpnet.POSTagger()
    pos_result = taggerPOS.tag(text)
    
    return pos_result


def syn_tree(text):
    """
    get text, process it with syntax stanford parser and return the generated trees. 
    if text is composed of one sentence, one tree will be returned
    """


    with open('/Users/erick/B2W/IntelligentSearch/temp/tokenized_query.txt','w') as temp:
        temp.write(text)


    #import ipdb; ipdb.set_trace()

    command_LX_Parser = '''java -Xmx256m -cp /Users/erick/B2W/IntelligentSearch/LX_Parser/stanford-parser-2010-11-30/stanford-parser.jar edu.stanford.nlp.parser.lexparser.LexicalizedParser -tokenized -sentences newline -outputFormat oneline -uwModel edu.stanford.nlp.parser.lexparser.BaseUnknownWordModel /Users/erick/B2W/IntelligentSearch/LX_Parser/stanford-parser-2010-11-30/cintil.ser.gz /Users/erick/B2W/IntelligentSearch/temp/tokenized_query.txt'''

    with open('/Users/erick/B2W/IntelligentSearch/temp/parsed_query.txt','w') as file_out:
        p = subprocess.call(shlex.split(command_LX_Parser), stdout=file_out)
    
    with open('/Users/erick/B2W/IntelligentSearch/temp/parsed_query.txt','r') as syntax_trees:
        trees = syntax_trees.readlines()
        return trees



def show_tree(root):
    if root is not None:
        for c in root.children:
            show_tree(c)
        print "{}\t{}".format(root.label,root.value)
    else:
        print "{}\t{}".format(root.label,root.value)


def get_chunk(root):
    chunk = []
    if root is not None:
        if root.value is not None:
            return root.value
        for c in root.children:
            chunk.append(get_chunk(c))

    return chunk
        

def get_sub_trees_by_tag(root, tag):
    list_trees = []
    if root is not None:
        if root.label is not None and root.label == tag:
            list_trees.append(root)
        for c in root.children:
            list_trees.append(get_sub_trees_by_tag(c,tag))

    return list_trees



def build_tree(parsed_text):
    print parsed_text
    stack_nodes = []
    char_list = list(parsed_text)

    def print_stack():
        print [s.label for s in stack_nodes]

    c = 0
    while c < len(char_list):
        # new node
        if char_list[c] == '(':

            # create a new node
            new_node = Node()
            stack_nodes.append(new_node)
            
            c += 1

            # search the label
            label = ''
            while char_list[c] != ' ':
                label = label + char_list[c]
                c += 1
            new_node.alter_values(label,None)
            c += 1

            # leaf node
            if char_list[c] != '(':
                value = ''
                while char_list[c] != ')':
                    value = value + char_list[c]
                    c += 1
                new_node.alter_values(label,value)

        #finish node and link to father
        if char_list[c] == ')':
            if len(stack_nodes) > 1:
                top_node = stack_nodes.pop()
                father = stack_nodes.pop()
                top_node.add_parent(father)
                father.add_child(top_node)
                stack_nodes.append(father)
                c += 1

                if char_list[c] == ' ':
                    c += 1

                elif char_list[c] == '\n':
                    return father
            else:
                top_node = stack_nodes.pop()
                return top_node

