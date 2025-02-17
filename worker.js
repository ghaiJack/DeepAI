export default {
    async fetch(request, env) {
      const url = new URL(request.url);
      
      // 处理API请求和其他请求
      url.host = 'xxx.hf.space';
      
      // 创建新的headers
      const headers = new Headers(request.headers);
      
      // 获取原始的Authorization header
      const originalAuth = headers.get('Authorization');
      
      // 使用HF token访问私人空间
      headers.set('Authorization', `Bearer ${env.HF_TOKEN}`);
      
      // 如果有原始的API key，添加为自定义header
      if (originalAuth) {
        headers.set('X-Original-Authorization', originalAuth);
      }
      
      const newRequest = new Request(url, {
        method: request.method,
        headers: headers,
        body: request.body
      });
      
      // 获取响应
      const response = await fetch(newRequest);
      
      // 创建新的响应，复制所有header
      const newHeaders = new Headers(response.headers);
      
      // 如果有原始Authorization，在响应中也使用它
      if (originalAuth) {
        newHeaders.set('Authorization', originalAuth);
      }
      
      return new Response(response.body, {
        status: response.status,
        statusText: response.statusText,
        headers: newHeaders
      });
    }
  }