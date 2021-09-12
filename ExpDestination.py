# _*_ coding: utf-8-sig _*_
# _author: 'sql'
# date: 2021/5/30
import requests
import time
import random
import os
import json
import re
import csv

# obtenir les donneer en utilisant le cookie, connecter le cookie
def get_cookie():
    # ouvrir le fichier cookie.txt en function open
    with open('cookie.txt', 'r')as f:
        cookie = f.read().strip()
        return cookie


class Spider: # le stockage
    def __init__(self):
        self.dir = 'resultat'  # stocker les données dans un dossier
        self.t = 'commentaires'  # nom de fichier
        self.num = 1  # count
        self.cookie = get_cookie()
        self.s = requests.session() # créer la coonection
        if not os.path.exists(self.dir):
            os.mkdir(self.dir)
        current_time = time.strftime('%Y-%m-%d-%H-%M-%S', time.localtime(time.time()))
        n = self.t  + '.csv'  # le nom de fichier
        path = os.path.join(self.dir, n)
        self.f = open(path, 'a+', encoding='utf-8-sig', buffering=1, newline='')
        fieldnames = ['id','Guest', 'Host', 'Time_Inscription','location', 'Time_Comment', 'comments'] # definir le nom de header de fichier csv
        self.writer = csv.DictWriter(self.f, fieldnames=fieldnames)
        self.writer.writeheader()

    # ici c'est analyser la page web
    def get_res(self, url):
        i = 1
        while i < 3:
            try:
                # time.sleep(random.uniform(3, 5))
                headers = {
                    'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
                    'cookie': self.cookie,
                    'user-agent': 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.77 Safari/537.36'
                }

                # demander la connexion de la web page, ici on essaie 2 fois, en cas d'échec,on arret la demande
                response = self.s.get(url, headers=headers, timeout=(5, 10))
                if response.status_code == 200:  # réponse réussie avec le code 200
                    return response
                else:
                    print('re-demander')
                    i += 1
                    time.sleep(random.uniform(2, 5))
                    continue
            except:
                print('error')
                i += 1
                time.sleep(random.uniform(2, 5))
                continue

    def parse(self, res, id):
        """
        详情
        :param res:
        :return:
        """
        reviewee_smartName = ''
        s = re.sub('\s+', '', res.text)
        # si on ne trouve pas la page d'utilisateur ou cette id n'exist pas alors laisser la ligne vide
        if re.findall("We can't seem to find the page you're looking for.", s, re.S):
            print("We can't seem to find the page you're looking for.")
            dic = {}
            dic['id'] = id
            dic['Time_Inscription'] = ''
            dic['Guest'] = reviewee_smartName
            dic['Host'] = ''
            dic['location'] = ''
            dic['Time_Comment'] = ''
            dic['comments'] = ''
            print(self.num, dic)
            self.num += 1
            self.writer.writerow(dic)
            return None
        # obtenir les donneer d'utilisateur
        # selon la regle de function re.findall, ici devrait extraire toutes les informations par le segment
        # on trouve 'data-state' et 'niobeMinimalClientData' dans le code html pour sélecter les informations nécessaires
        html = re.findall('data-state.*?>(.*?)</script>', s, re.S)[0]
        ds = json.loads(html)['niobeMinimalClientData']
        k = 0
        for d in ds:
            try:
                d2 = d[1]['data']['syd']['getUserInfo']['user'][
                    'recentReviewsFromGuest']  # le commentaire de guest
            except:
                d2 = []
            try:
                d1 = d[1]['data']['syd']['getUserInfo']['user'][
                    'recentReviewsFromHost']  # le commentaire de host
            except:
                d1 = []
            # combiner les deux comments
            d = d1 + d2
            if not d:
                continue
            f = 0
            # faire la retour de commentaire des guests
            for v in d:
                createdAt0 = v['reviewer']['createdAt']
                smartName = v['reviewer']['smartName']
                location = v['reviewer']['location']
                reviewee_smartName = v['reviewee']['smartName']
                comments = v['comments']
                createdAt = v['createdAt']

                # vérifier les données dans la code html equivalent le header qu'on a créé dans le fichier csv
                dic = {}
                dic['id'] = id
                dic['Time_Inscription'] = createdAt0
                # dic['smartName'] = smartName
                dic['Guest'] = reviewee_smartName
                dic['Host'] = smartName
                dic['location'] = location
                dic['Time_Comment'] = createdAt
                dic['comments'] = comments

                print(self.num, dic)
                f = 1
                self.num += 1
                self.writer.writerow(dic)

            # si il n'a pas de commentaire alors laisser la ligne vide
            if f == 0:
                dic = {}
                dic['id'] = id
                dic['Time_Inscription'] = ''
                dic['Guest'] = reviewee_smartName
                dic['Host'] = ''
                dic['location'] = ''
                dic['Time_Comment'] = ''
                dic['comments'] = ''

                print(self.num, dic)
                self.num += 1
                self.writer.writerow(dic)

    # pour changer la langue de different pays
    def run(self):
        # base_url = 'https://www.airbnb.cn/users/show/{}'  # China
        base_url = 'https://www.airbnb.com/users/show/{}?locale=en'  # USA
        # base_url = 'https://fr.airbnb.com/users/show/{}'  # France

        # on tirer les commentaire selon le id de guest
        with open('reviewer_id.csv', 'r')as f:
            i = 0
            readers = csv.reader(f)
            for reader in readers:
                if i < 1:
                    i += 1
                    continue
                # if i > 20:
                #     break
                # print(reader)
                j = 1
                # parfois il ne peut pas retour les donnees alors re essayer
                while j < 5:
                    id = reader[0].split(';')[-1]
                    # id = '89644664'
                    url = base_url.format(id)
                    print('collecting No.{} id,url=  {}'.format(i, url))
                    i += 1
                    res = self.get_res(url)
                    if res:
                        f = self.parse(res, id)
                        if f:
                            j += 1
                            continue
                            # self.parse0(res, id)
                        else:
                            break

        # save as excel and close
        self.f.close()

# calculer la durée pour collecter les données
if __name__ == '__main__':
    start = time.time()
    start_time = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(start))  # transformer le format

    s = Spider()
    s.run()

    finish = time.time()
    finish_time = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(finish))  # transformer le format
    Total_time = finish - start
    m, s = divmod(Total_time, 60)
    h, m = divmod(m, 60)
    print('start time:', start_time)
    print('end time:', finish_time)
    print("Total_time", "total time===>%dhour:%02dmin:%02dsecond" % (h, m, s))