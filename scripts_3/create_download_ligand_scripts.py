import pandas as pd
from argparse import ArgumentParser

# Parse the arguments
parser = ArgumentParser()
parser.add_argument("-file", required=True,
                    help="File to process")
parser.add_argument("-path_to_store_scripts", default="",
                    help="Path where to store scripts")
parser.add_argument("-path_to_store_ligands", default="",
                    help="Path where to store the ligands")
args = parser.parse_args()

set_to_process = pd.read_csv(args.file, 
                       delim_whitespace=True, header=None, names=["ZINC_ID"])
# Get only numerical part fo ZINC IDs (remove "ZINC")
set_to_process["ZINC_ID"] = set_to_process["ZINC_ID"].map(lambda x: x[4:])

# Get ZINC IDs
zinc_ids = list(set_to_process["ZINC_ID"])

# Create chunks of ZINC IDs of size 1000
chunks = [zinc_ids[x:x+1000] for x in range(0, len(zinc_ids), 1000)]

# Turn chunks into strings of format that will go to the curl command
chunks_in_string = []
for chunk in chunks:
    chunks_in_string.append("\r\n".join(chunk))
    
# Parts of CURL command to download batches/chunks of SDFs
curl_first_part = '''curl 'https://zinc20.docking.org/substances/resolved/' \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
  -H 'Accept-Language: sk-SK,sk;q=0.9,cs;q=0.8,en-US;q=0.7,en;q=0.6' \
  -H 'Cache-Control: max-age=0' \
  -H 'Connection: keep-alive' \
  -H 'Content-Type: multipart/form-data; boundary=----WebKitFormBoundary3PFsqZvV99a0nSHH' \
  -H 'Cookie: _ga=GA1.2.508312238.1655725625; PHPSESSID=il78hev7mv4gka4ggb47a375i1; _gid=GA1.2.1550734936.1657353286; _gat_gtag_UA_24210718_4=1; session=eyJfZnJlc2giOmZhbHNlLCJjc3JmX3Rva2VuIjoiMDdhMGU2YmEyNWQ1ZjUzYTZhMjA0MGU3N2UxMGJiYjM3YmI4NDI0NyJ9.YssFsg.E9MPTJ2CEcmvY9gOp258TxveVfg' \
  -H 'Origin: https://zinc20.docking.org' \
  -H 'Referer: https://zinc20.docking.org/substances/home/' \
  -H 'Sec-Fetch-Dest: document' \
  -H 'Sec-Fetch-Mode: navigate' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-User: ?1' \
  -H 'Upgrade-Insecure-Requests: 1' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36' \
  -H 'cp-extension-installed: Yes' \
  -H 'sec-ch-ua: ".Not/A)Brand";v="99", "Google Chrome";v="103", "Chromium";v="103"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  --data-raw $'------WebKitFormBoundary3PFsqZvV99a0nSHH\r\nContent-Disposition: form-data; name="paste"\r\n\r\n'''

curl_second_part = '''\r\n------WebKitFormBoundary3PFsqZvV99a0nSHH\r\nContent-Disposition: form-data; name="upload"; filename=""\r\nContent-Type: application/octet-stream\r\n\r\n\r\n------WebKitFormBoundary3PFsqZvV99a0nSHH\r\nContent-Disposition: form-data; name="identifiers"\r\n\r\ny\r\n------WebKitFormBoundary3PFsqZvV99a0nSHH\r\nContent-Disposition: form-data; name="structures"\r\n\r\ny\r\n------WebKitFormBoundary3PFsqZvV99a0nSHH\r\nContent-Disposition: form-data; name="names"\r\n\r\ny\r\n------WebKitFormBoundary3PFsqZvV99a0nSHH\r\nContent-Disposition: form-data; name="retired"\r\n\r\ny\r\n------WebKitFormBoundary3PFsqZvV99a0nSHH\r\nContent-Disposition: form-data; name="charges"\r\n\r\ny\r\n------WebKitFormBoundary3PFsqZvV99a0nSHH\r\nContent-Disposition: form-data; name="scaffolds"\r\n\r\ny\r\n------WebKitFormBoundary3PFsqZvV99a0nSHH\r\nContent-Disposition: form-data; name="multiple"\r\n\r\ny\r\n------WebKitFormBoundary3PFsqZvV99a0nSHH\r\nContent-Disposition: form-data; name="output_format"\r\n\r\nsdf\r\n------WebKitFormBoundary3PFsqZvV99a0nSHH--\r\n' \
  --compressed'''

# Build individual bash script for each batch/chunk.
for index,chunk in enumerate(chunks_in_string):
    output_name = args.path_to_store_ligands + "/chunk_" + str(index)+ ".sdf"
    curl_command = curl_first_part + chunk + curl_second_part + " > " + output_name + "\n"
    number_of_lines_in_file_command = 'x=$(wc -l < ' + output_name + ' )\n'
    # Retry command is used if the request has failed (output file has <1000 lines). 
    retry_command = 'if [ $x -lt 1000 ];\n then\n ' + 'echo "Retrying download as request failed"\n' + curl_command + ' fi\n'
    with open (args.path_to_store_scripts + '/download_chunk_' + str(index) + '.sh', 'w') as script:
            script.write('#! /bin/bash\n')
            script.write('module load curl-7.63.0-intel-17.0.4-lxwgw2f\n') # load newer version of CURL (relevant on CSD3 only)
            script.write(curl_command)
            # If request fail, retry up to 5 times. This is done this way and not with --retry curl option so we do not 
            # have faulty html snippet in the output sdf file.
            script.write(number_of_lines_in_file_command)
            script.write(retry_command)
            script.write(number_of_lines_in_file_command)
            script.write(retry_command)
            script.write(number_of_lines_in_file_command)
            script.write(retry_command)
            script.write(number_of_lines_in_file_command)
            script.write(retry_command)
            script.write(number_of_lines_in_file_command)
            script.write(retry_command)
