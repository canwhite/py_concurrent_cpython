# http_client.pyx
from libc.stdlib cimport malloc, free
from libc.string cimport strcpy, strlen
from cpython.bytes cimport PyBytes_FromString
import socket
import json

cdef class HttpClient:
    cdef public str host
    cdef public int port
    
    def __init__(self, str host, int port=80):
        self.host = host
        self.port = port
    
    cpdef dict get(self, str path, dict headers=None):
        if headers is None:
            headers = {}
        
        request = self._build_request(b'GET', path.encode(), headers)
        return self._send_request(request)
    
    cpdef dict post(self, str path, dict data=None, dict headers=None):
        if headers is None:
            headers = {}
        if data is None:
            data = {}
            
        # 添加content-type
        headers['Content-Type'] = 'application/json'
        body = json.dumps(data).encode()
        headers['Content-Length'] = str(len(body))
        
        request = self._build_request(b'POST', path.encode(), headers, body)
        return self._send_request(request)
    
    cdef bytes _build_request(self, bytes method, bytes path, dict headers, bytes body=b''):
        cdef list request_parts = []
        
        # 添加请求行
        request_parts.append(b'%s %s HTTP/1.1' % (method, path))
        
        # 添加Host头
        request_parts.append(b'Host: %s' % self.host.encode())
        
        # 添加其他headers
        for key, value in headers.items():
            header_line = f'{key}: {value}'.encode()
            request_parts.append(header_line)
        
        # 组合请求
        request = b'\r\n'.join(request_parts)
        request += b'\r\n\r\n'
        
        if body:
            request += body
            
        return request
    
    cdef dict _send_request(self, bytes request):
        cdef:
            bytes response
            dict result = {}
        
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
                sock.connect((self.host, self.port))
                sock.sendall(request)
                
                response = b''
                while True:
                    data = sock.recv(4096)
                    if not data:
                        break
                    response += data
                
                return self._parse_response(response)
        except Exception as e:
            return {'error': str(e)}
    
    cdef dict _parse_response(self, bytes response):
        cdef:
            dict result = {}
            list parts
            list header_lines
            str status_line
            
        try:
            decoded_response = response.decode('utf-8')
            parts = decoded_response.split('\r\n\r\n', 1)
            header_lines = parts[0].split('\r\n')
            status_line = header_lines[0]
            
            # 解析状态行
            status_parts = status_line.split(' ', 2)
            result['status_code'] = int(status_parts[1])
            
            # 解析headers
            headers = {}
            for line in header_lines[1:]:
                if ':' in line:
                    key, value = line.split(':', 1)
                    headers[key.strip()] = value.strip()
            result['headers'] = headers
            
            # 解析body
            if len(parts) > 1:
                try:
                    result['content'] = json.loads(parts[1])
                except json.JSONDecodeError:
                    result['content'] = parts[1]
                    
            return result
        except Exception as e:
            return {'error': str(e)}