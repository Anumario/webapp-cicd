FROM node:18

WORKDIR /app

# copier les manifestes en premier pour une mise en cache efficace
COPY package*.json ./

# installer TOUT (prod + dev) pour permettre l'exécution de tests à l'intérieur de l'image
RUN npm install

# copiez maintenant le reste du code
COPY . .

# porte de app
EXPOSE 3000

# commande par défaut (pour lorsque vous exécutez le conteneur en production)
CMD ["node", "server.js"]

