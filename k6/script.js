import http from 'k6/http';
import { check, sleep } from 'k6';
export let options = {
    vus: 10,
    maxDuration: '60m',
};
export default function () {
    let response = http.get(`${__ENV.UI_ENDPOINT}`);
    check(response, {
        'status is 200': (r) => r.status === 200,
    });
    sleep(1);
}