import xml.etree.ElementTree as ET
import re
import json
import os

def remove_newlines(text):
    return text.replace("\n", "").replace("    ", "")

def get_figura(figuras):
    imagem = ""
    legenda = ""

    for child in figuras:
        if child.tag == "imagem":
            grupos = re.search(r'\.\.\/imagem\/(.*)', child.attrib["path"])
            imagem ="MapaRuas-materialBase/imagem/" + grupos.group(1)
        elif child.tag == "legenda":
            legenda = child.text

    return {
        "imagem": imagem,
        "legenda": legenda
    }

def get_text_from_element(element):
    text = element.text if element.text else ""
    for child in element:
        text += remove_newlines(get_text_from_element(child))
        if child.tail:
            text += child.tail
    return text

def get_desc(desc):
    descricao = ""
    for child in desc:
        if child.tag == "para":
            descricao = remove_newlines(get_text_from_element(child))
    return descricao

def get_casa(casa):
    numero = ""
    enfiteuta = ""
    foro = ""
    descricao = ""
    for child in casa:
        if child.tag == "número":
            numero = child.text
        elif child.tag == "enfiteuta":
            enfiteuta = child.text
        elif child.tag == "foro":
            foro = child.text
        elif child.tag == "desc":
            descricao = get_desc(child)
    return {
        "numero": numero,
        "enfiteuta": enfiteuta,
        "foro": foro,
        "descricao": descricao
    }

def get_casas(lista_casas):
    casas = []
    for casa in lista_casas:
        if casa.tag == "casa":
            casas.append(get_casa(casa))
    return casas

def get_corpo(corpo):
    dic = {
        "figuras": [],
        "descricao": "",
        "casas": []
    }
    for child in corpo:
        if child.tag == "figura":
            figura = get_figura(child)
            dic["figuras"].append(figura)
        elif child.tag == "para":
            dic["descricao"] += remove_newlines(get_text_from_element(child)) 
        elif child.tag == "lista-casas":
            dic["casas"] = get_casas(child)
    return dic

def get_meta(meta):
    numero = -1
    nome = ""
    for child in meta:
        if child.tag == "número":
            numero = int(child.text)
        elif child.tag == "nome":
            nome = child.text
    return numero, nome

def parse_file(filename):
    tree = ET.parse(filename)

    root = tree.getroot()
    rua = {}
    for child in root:
        if child.tag == "meta":
            numero, nome = get_meta(child)
            rua["numero"] = numero
            rua["nome"] = nome
        elif child.tag == "corpo":
            dic = get_corpo(child)
            rua.update({key: dic[key] for key in ["figuras", "descricao", "casas"]})
    return rua

def add_figuras_atuais(rua, numero):
    rua["figuras_atuais"] = []
    for fig in os.listdir("MapaRuas-materialBase/atual"):
        if re.match(r"{}-.*".format(numero), fig):
            rua["figuras_atuais"].append({
                "imagem": "MapaRuas-materialBase/atual/" + fig,
            })

if __name__ == "__main__":
    ruas = []
    for filename in os.listdir("MapaRuas-materialBase/texto"):
        if filename.endswith(".xml"):
            rua = parse_file("MapaRuas-materialBase/texto/" + filename)
            add_figuras_atuais(rua,str(rua["numero"]))
            ruas.append(rua)

    ruas.sort(key=lambda x: x["numero"])
    with open("priv/fake/roads.json", "w") as f:
        f.write(json.dumps(ruas, indent=4, ensure_ascii=False))
