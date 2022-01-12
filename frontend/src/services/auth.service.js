import axios from 'axios';

const API_URL = 'http://localhost/api/v1/user/';

class AuthService {
  login(user) {
    return axios
      .post(API_URL + 'sign/in', {
        email: user.email,
        password: user.password
      })
      .then(response => {
        if (response.data.tokens.access) {
          var { access, refresh} = response.data.tokens
          localStorage.setItem('user', JSON.stringify({
            "email": user.email,
            "access": access,
            "refresh": refresh
          }));
        }

        return response.data;
      });
  }

  logout() {
    localStorage.removeItem('user');
  }

  register(user) {
    return axios.post(API_URL + 'sign/up', {
      email: user.email,
      password: user.password
    });
  }
}

export default new AuthService();
