# coding=utf-8

"""
Implements a tree structure
"""

class Node:
    def __init__(self, label=None, value=None, parent=None):
        self.label = label
        self.value = value
        self.children  = []
        self.parent = parent

    def alter_values(self, label, value):
        self.label = label
        self.value = value

    def add_child(self, child):
        self.children.append(child)

    def add_parent(self, parent):
        self.parent = parent