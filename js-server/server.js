const http = require('http')
const fs = require('fs')
const url = require('url')
const port = process.argv[2]

if(!port) {
    console.log('请指定端口号！')
    process.exit(1)
}

var server = http.createServer((request, response)=>{
    let method = request.method
    if('GET' === method){
        let parsedUrl = url.parse(request.url, true)
        let pathWithQUery = request.url
        let queryString = ''
        if(pathWithQUery.indexOf('?') >= 0){
            queryString = pathWithQUery.substring(pathWithQUery.indexOf('?'))
        }
        
        fs.appendFileSync('./demo.txt', queryString + '\n', {'encoding': 'utf8'})
    }else if('POST' === method){
        let data
        request.on('data', res => {
            data = res
        })
        request.on('end', ()=>{
            let encode = data.encrypt
            
        })
    }
    response.statusCode = 200
    response.setHeader('Content-Type', 'text/plain; charset=utf-8')
    response.end('我已接收到消息！！！')
})

server.listen(port)