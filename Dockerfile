FROM node:18

WORKDIR /app

COPY app/package*.json ./

RUN npm install

COPY app .

RUN useradd -m -d /home/appuser appuser
USER appuser

EXPOSE 3000

CMD ["node", "app.js"]